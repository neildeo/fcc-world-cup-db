#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Reset database
echo $($PSQL "truncate table games, teams;")

# Read games.csv and parse info
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Check value of YEAR to skip first round
  if [[ $YEAR != year ]]; then
    # Check if winner/opponent are previously unseen by querying database
      # Query team_id of winner; save to variable
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
      # Query team_id of opponent; save to variable
      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    # If winner is unseen, add to teams table and redefine winner_id variable
    if [[ -z $WINNER_ID ]]; then
      echo New team found: $WINNER
      echo $($PSQL "insert into teams(name) values('$WINNER');")
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    fi
    # If opponent is unseen, add to teams table and redefine opponent_id variable
    if [[ -z $OPPONENT_ID ]]; then
      echo New team found: $OPPONENT
      echo $($PSQL "insert into teams(name) values('$OPPONENT');")
      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    fi
    # Add row to games table
    GAME_INSERT_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS);")
    if [[ $GAME_INSERT_RESULT == "INSERT 0 1" ]]; then
      echo "Successfully added game record for $YEAR, $ROUND"
    fi
  fi
done