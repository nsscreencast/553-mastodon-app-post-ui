#!/bin/bash

echo "What is your Team ID? (looks like 1A23BDCD)"
read TEAM_ID

if [ -z "$TEAM_ID" ]; then
  echo "You must enter a team id"
  exit 1
fi

echo "DEVELOPMENT_TEAM_ID = $TEAM_ID" > Oliphaunt/App/Config/TeamID.xcconfig

