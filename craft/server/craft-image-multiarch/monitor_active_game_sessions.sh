#!/bin/bash 

export PGUSER=`cat $SECRET_FILE | jq -r '.username'`
export PGDATABASE=`cat $SECRET_FILE | jq -r '.username'`
export PGPASSWORD=`cat $SECRET_FILE | jq -r '.password'`
export PGHOST=`cat $SECRET_FILE | jq -r '.host'`
export PGPORT=`cat $SECRET_FILE | jq -r '.port'`

game_server_end_point=$(curl -s -H "Content-Type: application/json" -X GET http://localhost:${AGONES_SDK_HTTP_PORT}/gameserver | jq '.status | .address + " " + (.ports[].port|tostring)')

psql -A -q -t -w -c "
/*monitor_active_game_sessions*/ insert into game_server_pool (created_at,updated_at,endpoint,pod,status) values (NOW(),NOW(),'""$game_server_end_point""','""$MY_POD_NAME""',1);
"
echo "psql exit code="$?

max_sessions_per_game_server=$MAX_SESSIONS_IN_GS
cooldown_after_scale_up=$SCALE_UP_COOLDOWN
is_cooled_down=0
while true
do
  current_num_of_game_servers=$(kubectl get fleet $DEPLOY_NAME | grep -v NAME | awk '{print $4}')
  num_of_active_sessions=$(netstat -anp | grep $(/sbin/ip addr| grep inet | grep -v inet6| grep -v 127.0.0.1| awk '{print $2}'| awk -F\/ '{print $1}') | grep 4080 | grep ESTABLISHED| wc -l)
  echo `date` num_of_active_sessions=$num_of_active_sessions num_of_game_servers=$current_num_of_game_servers
  if (( $num_of_active_sessions == 0 ))
  then
    curl -s -d "{}" -H "Content-Type: application/json" -X POST http://localhost:${AGONES_SDK_HTTP_PORT}/ready
  fi
  if (( $num_of_active_sessions >= $max_sessions_per_game_server ))
  then
    if (( $is_cooled_down == 0 ))
    then
      echo "game server is at capacity; max_sessions_per_game_server=$max_sessions_per_game_server going to add more servers"
      new_num_of_game_servers=$(echo $(( $current_num_of_game_servers + 1 )))
      kubectl scale fleet $DEPLOY_NAME --replicas=$new_num_of_game_servers
      echo cooling down for $cooldown_after_scale_up sec
      sleep $cooldown_after_scale_up
      is_cooled_down=1
    else
      echo "game server already scaled so removing it from the loadbalancer target group"
      if (( $num_of_active_sessions > 10 ))
      then
        rm -f /tmp/healthy
        echo "reached the game server hard limit - going to exclude the server from the LB target group"
      fi
    fi
    aws cloudwatch put-metric-data --metric-name num_of_game_servers --namespace craft --value $new_num_of_game_servers
  else
    aws cloudwatch put-metric-data --metric-name num_of_game_servers --namespace craft --value $current_num_of_game_servers
    is_cooled_down=0
  fi
  
  sleep 5
done