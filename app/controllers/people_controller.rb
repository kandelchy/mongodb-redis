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
    1000000.times do
      # Make sure at least one slave is up and running beside Master`
      while $REDIS.wait(2,1000) == 0
       puts "Waiting for Slave"
       sleep 10
      end

      $messageno=$messageno+1
      #  puts $messageno
      #  puts @person.message
      # puts $REDIS.set("Message: #{$messageno}", @person.message )
      $REDIS.set("Message: #{$messageno}", "#{message_text} #{$messageno}" )

      redis_value = $REDIS.get("Message: #{$messageno}")
      # pp "----------------------------------------"
      #
      # pp redis_value


      @person = Person.new(message:redis_value)
      @person.save
      # if @person.save
      #  redirect_to root_path, notice: "The message has been saved from redis to mongodb" and return
      # end
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
 end

  def person_params
    params.require(:person).permit(:message,:redis_value)
  end
end
