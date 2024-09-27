#! /bin/bash

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

  echo -e "\n~~~~~ MY SALON ~~~~~\n"


MAIN_MENU () {

  if [[ $1 ]] 
  then
  echo -e "\n$1"
  else
  echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  
  services=$($PSQL "select service_id , name from services")
  
  echo "$services" | while IFS='|' read SERVICE_ID NAME
  do
  echo -e "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  existed_service=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED");

  if [[ -z $existed_service ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else

  service_name=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED");
    
  echo -e "\nWhat's your phone number?"
  
  read CUSTOMER_PHONE
  
  existed_phone=$($PSQL "select phone from customers where phone = '$CUSTOMER_PHONE'");
  
  if [[ -z $existed_phone ]]
  then
  
  echo -e "\nI don't have a record for that phone number, what's your name?";
  
  read CUSTOMER_NAME

  insert_customer=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME' , '$CUSTOMER_PHONE')");

  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"

  read SERVICE_TIME

  customer_id=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'");

  insert_appointment=$($PSQL "insert into appointments (customer_id , service_id, time) values ($customer_id,$SERVICE_ID_SELECTED,'$SERVICE_TIME' )");

  echo -e "\nI have put you down for a $service_name at $SERVICE_TIME, $CUSTOMER_NAME.";

  else

  customer=$($PSQL "select * from customers where phone='$CUSTOMER_PHONE'");
  
 IFS="|" read ID PHONE NAME <<< "$customer"
  
  echo -e "\nWhat time would you like your color, $NAME?"
  read SERVICE_TIME
  insert_appointment=$($PSQL "insert into appointments (customer_id , service_id, time) values ($ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME' )");
  echo -e "\nI have put you down for a $service_name at $SERVICE_TIME, $NAME.";

  fi
  fi
}


MAIN_MENU 