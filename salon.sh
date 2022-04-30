#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

IFS=" | "

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


while :
do
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while read ID SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  read SERVICE <<< "$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
  echo "$SERVICE"
  if [[ -z $SERVICE ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    read CUSTOMER_ID CUSTOMER_NAME <<< "$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_ID="$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE') RETURNING customer_id" -q)"
    fi
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    APPOINTMENT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
    if [[ $APPOINTMENT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
      break
    else
      echo -e "\nAn error occurred: the appointment wasn't stored\n"
    fi
  fi
done
