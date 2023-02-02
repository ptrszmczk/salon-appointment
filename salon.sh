#!/bin/bash

Q="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_RESULT=$($Q "select * from services")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  COUNT=0
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo "Q) Exit"


  echo -e "\nInput service number:"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-3]) LOG_TO_ACCOUNT "$SERVICE_ID_SELECTED" ;;
    "q" | "Q") exit 0 ;;
    *) MAIN_MENU "This is not correct number!"
  esac
}

LOG_TO_ACCOUNT() {
  echo -e "\nInput your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_PHONE_RESULT=$($Q "select * from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_PHONE_RESULT ]]
  then
    echo -e "\nTo create new account input your name:"
    read CUSTOMER_NAME

    ADD_CUSTOMER_RESULT=$($Q "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($Q "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  ADD_APPO "$CUSTOMER_ID" "$1"
}

ADD_APPO() {
  echo -e "\nWhat time to make an appointment?"
  read SERVICE_TIME

  if [[ -z $SERVICE_TIME ]]
  then
    APPOINTMENT_RESULT=$($Q "insert into appointments(customer_id, service_id, time) values($1, $2, NOW())")
  else
    APPOINTMENT_RESULT=$($Q "insert into appointments(customer_id, service_id, time) values($1, $2, '$SERVICE_TIME')")
  fi

  SERVICE_RESULT=$($Q "select name from services where service_id=$2")
  NAME_RESULT=$($Q "select name from customers where customer_id=$1")
  echo -e "\nI have put you down for a$SERVICE_RESULT at $SERVICE_TIME,$NAME_RESULT."
  exit 0
}

MAIN_MENU