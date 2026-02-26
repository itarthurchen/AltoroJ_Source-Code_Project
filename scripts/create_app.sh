as360Token=$(curl -k -s -X POST --header 'Content-Type:application/json' --header 'Accept:application/json' -d '{"KeyId":"'"$APPSCAN_KEY"'","KeySecret":"'"$APPSCAN_SECRET"'"}' "https://$serviceUrl/api/v4/Account/ApiKeyLogin" | grep -oP '(?<="Token":\ ")[^"]*')
if [ -z "$as360Token" ]; then
	echo "The token variable is empty or wrong. Check the API keys.";
    exit 1
fi

assetGroupIdExist=$(curl -k -s -X 'GET' "https://$serviceUrl/api/v4/AssetGroups" -H 'accept: application/json' -H "Authorization: Bearer $as360Token" | grep "$assetGroupId")
if [ -z "$assetGroupIdExist" ]; then
        echo "Asset Group ID does not exist or wrong. Check the Asset Group ID.";
    exit 1
fi

appId=$(curl -s -k -X GET --header 'Authorization: Bearer '"$as360Token"'' --header 'Accept:application/json' "https://$serviceUrl/api/v4/Apps?%24top=5000&%24filter=Name%20eq%20%27$as360AppName%27&%24select=name%2Cid&%24count=false" | grep -oP '(?<="Id":\ ")[^"]*')
if [ -z "$appId" ]; then
	appId=$(curl -s -k -X POST --header "Authorization: Bearer $as360Token" --header 'Accept:application/json' --header 'Content-Type: application/json' -d '{"Name":"'"$as360AppName"'","AssetGroupId":"'"$assetGroupId"'","UseOnlyAppPresences":false}' "https://$serviceUrl/api/v4/Apps" | grep -oP '(?<="Id": ")[^"]*' | head -n 1);
	echo "There is no $as360AppName application. It was created. The appId is $appId";
else 
	echo "Application name $as360AppName exist. The appId is $appId."
fi

if [ -z "$appId" ]; then
        echo "Something went wrong while checking if the application ID exists. Check the ASoC Keys and AssetGroupId variables.";
    exit 1
fi

echo $appId > appId.txt

curl -k -s -X 'GET' "https://$serviceUrl/api/v4/Account/Logout" -H 'accept: */*' -H "Authorization: Bearer $as360Token"
