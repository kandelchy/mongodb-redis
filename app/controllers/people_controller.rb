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

    message_text = "Testing Redis and MongoDB, message No. "
    log = Logger.new('mylog.log')
    log.info 'Log file for succeeded and failed message of the performance test for 1 million messages'
    success=0
    failed=0
    time_diff=0
    min_response = 1
    max_response = 0
    total_time = 0
    avg_response = 0
    1000000.times do
      begin
        start_time = Time.now
        # Make sure at least one slave is up and running beside Master`
        while $REDIS.wait(2,1000) == 0
          log.info 'Message failed'
          log.error e
          failed = failed + 1
          puts "Waiting for Slave"
          sleep 10
        end

        $messageno = $messageno + 1

        $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )
        redis_value = $REDIS.get("Message: #{$messageno}")
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
        log.info "Message success, Time= #{time_diff}"

      rescue Exception => e
        # puts "failed?", e
        log.info 'Message failed'
        log.error e
        failed = failed + 1
      end

    end
    avg_response = total_time / 1000000  #Change this to number of messages you are running
    puts "Message succeeded: #{success}"
    puts "Message failed: #{failed}"
    puts "Minimum time response: #{min_response}"
    puts "Maximum time response: #{max_response}"
    puts "Average time reponse: #{avg_response}"
    redirect_to root_path, notice: "Messages have been saved from redis to mongodb" and return
end

     # data = (0..100).map do |i|
     #   { :a =>"this message num#{i}"   }
     # end
     # $redis.set(:key , data)



    #@person = Person.create(message:redis_value)


   # if @person.save
   #redirect_to root_path, notice: " has been updated! from redis" and return
    #end




  #  respond_to do |format|
  #    if @person.save
  #      format.html { redirect_to @person, notice: 'Upload was successfully created.' }
  #      format.json { render :show, status: :created, location: @person }
  #    else
  #      format.html { render :new }
  #      format.json { render json: @person.errors, status: :unprocessable_entity }
  #    end
  #  end


  def person_params
    params.require(:person).permit(:message,:redis_value)
  end
end
