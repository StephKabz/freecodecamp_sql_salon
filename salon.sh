#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MY_SERVICE(){
  local PARAM_NAME="$1"
  local PARAM_ID="$2"

  # READ PHONE NUMBER
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # CHECK CUSTOMER BY PHONE NUMBER IN DATABASE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  #if customer is not in database
  if [[ -z $CUSTOMER_ID ]]
  then
    #ask for customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #add customer to database
    NAME_FORMATED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
    ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$NAME_FORMATED');")

    #if insertion succeed
    if [[ $ADD_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nInserted new clients $NAME_FORMATED with phone number $CUSTOMER_PHONE"
    else
      echo -e "\nError could not insert client to database"
    fi

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  else
    #get name of customer id in database
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID';")
    NAME_FORMATED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
  fi

  #customer id without any space
  CUSTOMER_ID_FORMATED=$(echo $CUSTOMER_ID | sed 's/^ *| *$//g')

  #get time
  echo -e "\nWhat time would you like your $PARAM_NAME, $NAME_FORMATED?"
  read SERVICE_TIME

  #add appointments with customer info
  ADD_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES ($CUSTOMER_ID_FORMATED, '$SERVICE_TIME', $PARAM_ID);")

  #check that insertion succeed
  if [[ $ADD_APPOINTMENTS_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $PARAM_NAME at $SERVICE_TIME, $NAME_FORMATED."
  else
    echo -e "\nError could not add appointments to database"
  fi

}

MAIN_MENU()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  S_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  if [[ -z $S_ID ]]
  then
   MAIN_MENU "I could not find that service. What would you like today?"
   else
	S_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$S_ID'")

	SERVICE_NAME_FORMATED=$(echo $S_NAME | sed 's/^ *| *$//g')
	SERVICE_ID_FORMATED=$(echo $S_ID | sed 's/^ *| *$//g')

	MY_SERVICE "$SERVICE_NAME_FORMATED" "$SERVICE_ID_FORMATED"
  fi
}

MAIN_MENU