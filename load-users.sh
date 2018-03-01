#!/bin/bash
# Requires a DOMAIN, CSV file, and TARGET
# if [ $# -eq 0 ]
# then
#     echo "Must provide a CSV filename formatted as follows:"
#     echo "username,password"
#     exit 0
# fi
# Create one account for each line in the CSV file
#while IFS=',' read -r username password
#do
#    create_account $username $password
#done < $1

USERPREFIX=user
USERPASS=loadgen

DEFAULTDOMAIN=loadgen.zmc.com

if [ -z "$DOMAIN" ];
then
    echo "WARNING: $DOMAIN is not set in the environment. Defaulting to $DEFAULTDOMAIN."
    DOMAIN=$DEFAULTDOMAIN
fi


fetch_authtoken ()
{
    cat > payload.txt<<EOF
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <AuthRequest xmlns="urn:zimbraAdmin" name="$ADMIN" password="$ADMIN_PASS"></AuthRequest>
  </soap:Body>
</soap:Envelope>
EOF
    curl -k -X POST -H \"Content-Type:application/soap+xml\" https://$TARGET:$ADMIN_PORT/service/admin/soap --data-binary @payload.txt > response.txt
    TOKEN=`xmlstarlet sel -N zimbra="urn:zimbraAdmin" -N soap="http://www.w3.org/2003/05/soap-envelope" -t -v "/soap:Envelope/soap:Body/zimbra:AuthResponse/zimbra:authToken" response.txt`
    rm response.txt payload.txt
    echo $TOKEN
}

AUTHTOKEN=$(fetch_authtoken)
echo "Auth Token: ${AUTHTOKEN}"

build_createaccount()
{
    echo '<CreateAccountRequest xmlns="urn:zimbraAdmin" name="$1@$DOMAIN" password="$2"></CreateAccountRequest>'
}

create_account()
{
    cat > payload.txt <<EOF
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <context xmlns="urn:zimbra">
      <authToken>$AUTHTOKEN</authToken>
    </context>
  </soap:Header>
  <soap:Body>
    <CreateAccountRequest xmlns="urn:zimbraAdmin" name="$1@$DOMAIN" password="$2"></CreateAccountRequest>
  </soap:Body>
</soap:Envelope>
EOF
    curl -k -X POST -H 'Content-Type:application/soap+xml' https://$TARGET:$ADMIN_PORT/service/admin/soap --data-binary @payload.txt > response.txt
    cat response.txt
}

create_domain()
{
    cat > payload.txt <<EOF
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <context xmlns="urn:zimbra">
      <authToken>$AUTHTOKEN</authToken>
    </context>
  </soap:Header>
  <soap:Body>
    <CreateDomainRequest xmlns="urn:zimbraAdmin" name="$DOMAIN"></CreateDomainRequest>
  </soap:Body>
</soap:Envelope>
EOF
    curl -k -X POST -H 'Content-Type:application/soap+xml' https://$TARGET:$ADMIN_PORT/service/admin/soap --data-binary @payload.txt > response.txt
    cat response.txt
}

create_accounts() {
    # Creates a CSV file for usage by Jmeter & creates accounts on target server in the $DOMAIN
    for i in `seq 1 $1`;
    do
        echo "$USERPREFIX$i,$USERPASS" >> users.csv
        create_account "$USERPREFIX$i" $USERPASS
    done
}

# Create the domain in which we will be creating accounts
create_domain
create_accounts $NUM_ACCOUNTS
