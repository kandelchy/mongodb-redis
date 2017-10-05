class PeopleController < ApplicationController
  require "redis"

  def index
    @people = Person.all
  end

  def new
    @person = Person.new



  end

  def create

    data = (0..100).map do |i|
      { :a =>"this message num#{i}"   }
    end
    $redis.set(:key , data)

    redis_value = $redis.get(:key)
    pp "----------------------------------------"

    pp redis_value


   #@person = Person.create(message:redis_value)

   @person = Person.new(message:redis_value)

     if @person.save

       redirect_to root_path, notice: "The message has been save from redis to mongodb" and return
     end
  # if @person.save
  #redirect_to root_path, notice: " has been updated! from redis" and return
   #end






  end



  def person_params
    params.require(:person).permit(:message,:redis_value)
  end
end
