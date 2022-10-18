#! /bin/bash
dom=$1
echo -e "enumeration of subdomain is in process"
notification()
{
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "+++++finding live domains+++++"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
notification_1()
{
echo "=============================="
echo "+++++++++++completed++++++++++"
echo "=============================="
}
}
notification_2()
{
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "++++++sorting duplicate subdomains+++++++++"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

}
subdomain_enum()
{

for ast in --subs-only ; do
	
	assetfinder $ast $dom
	
done >> subdomains.txt

}


probe()
{

cat subdomains.txt | httprobe

}

rmv()
{

 while read url; do
     echo ${url#*//} >>to_sort.txt
	
done < subdomains.txt

}
sorting()

{
sort -u to_sort.txt | tee ennumeration_result.txt


}

   if [[ -z $dom ]]; then
echo "invalid syntax please input domain"
echo " eg : ./sublist.sh (domain)"
else 
   subdomain_enum
   notification
   probe
   notification_1
   rmv
   notification_2
   sorting
   notification_1
   rm subdomains.txt
   rm to_sort.txt
 fi