class PeopleController < ApplicationController
  require "redis"

  def index
    @people = Person.all
  end

  def new
    @person = Person.new
  end

  def create
    # @person = Person.new(person_params)

    message_text = 'Testing Redis and MongoDB, message No. '
    log = Logger.new('mylog.log')
    log.info 'Log file for succeeded and failed message of the performance test for 1 million messages'
    success=0
    failed=0
    time_diff=0
    min_response = 1
    max_response = 0
    total_time = 0
    avg_response = 0
    5000.times do
      begin
        $messageno = $messageno + 1
        start_time = Time.now
        # Make sure at least one slave is up and running beside Master
        puts "No of slaves is: #{$REDIS.wait(2,1000)}"
        while $REDIS.wait(2,1000) == 0
          log.info 'Message failed, No slaves available'
          # log.error e
          failed = failed + 1
          puts 'Waiting for Slave'
          sleep 10
        end
        # $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )
        redis_resp = $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )
        # puts redis_resp
        if redis_resp != 'OK'
          log.info 'Message NOT saved to REDIS'
          puts 'REDIS not available, NO SET'
        else
          redis_value = $REDIS.get("Message: #{$messageno}")
          puts redis_value
          if redis_value == nil
            log.info 'Message NOT loaded from REDIS'
            puts 'REDIS not available, NO GET'
          else
            @person = Person.new(message:redis_value)
            @person.save
            success=success+1
            current_time = Time.now
            time_diff = Time.now - start_time
            if time_diff < min_response
              min_response = time_diff
            end
            if time_diff > max_response
              max_response = time_diff
            end
            total_time = total_time + time_diff
            log.info "Message success, No. #{$messageno} Time= #{time_diff}"
            puts 'MESSAGE saved'
          end
        end
      rescue Exception => e
        log.info 'Message failed, connection lost'
        # log.error e
        failed = failed + 1
        sleep 10
        # Resend message
        redis_resp = $REDIS.set("Message: #{$messageno}", "REVISED: #{message_text} #{$messageno}" )
        redis_value = $REDIS.get("Message: #{$messageno}")
        @person = Person.new(message:redis_value)
        @person.save
      end
    end
    avg_response = total_time / 5000  #Change this to number of messages you are running
    puts "Message succeeded: #{success}"
    puts "Message failed: #{failed}"
    puts "Minimum time response: #{min_response}"
    puts "Maximum time response: #{max_response}"
    puts "Average time reponse: #{avg_response}"
    redirect_to root_path, notice: 'Messages have been saved from redis to mongodb' and return
  end

  def create_for_postman
    # This function will take one message, uploaded it to REDIS then downloaded to DB
    # Please comment function Create above and change the name of this one to create
    message_text = params[:message]
    begin
      $messageno = $messageno + 1
      # Make sure at least one slave is up and running beside Master
      while $REDIS.wait(2,1000) == 0
        # log.info 'Message failed, No slaves available'
        # log.error e
        puts 'Waiting for Slave'
        sleep 10
      end
      # $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )
      redis_resp = $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )
      # puts redis_resp
      if redis_resp != 'OK'
        # log.info 'Message NOT saved to REDIS'
        puts 'REDIS not available, NO SET'
      else
        redis_value = $REDIS.get("Message: #{$messageno}")
        puts redis_value
        if redis_value == nil
          # log.info 'Message NOT loaded from REDIS'
          puts 'REDIS not available, NO GET'
        else
          @person = Person.new(message:redis_value)
          @person.save
          # log.info "Message success, No. #{$messageno} Time= #{time_diff}"
          puts 'MESSAGE saved'
        end
      end
    rescue Exception => e
      # log.info 'Message failed, connection lost'
      # log.error e
      sleep 10 # Give enough time for Sentinel to promote new Master
      # Resend message
      redis_resp = $REDIS.set("Message: #{$messageno}", "REVISED: #{message_text} #{$messageno}" )
      redis_value = $REDIS.get("Message: #{$messageno}")
      @person = Person.new(message:redis_value)
      @person.save
    end
  end



  def person_params
    params.require(:person).permit(:message,:redis_value)
  end
end
