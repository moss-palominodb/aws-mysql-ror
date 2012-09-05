class AwsController < ApplicationController
  require 'net/http'
  require 'net/ssh'


#  def region
#    @region = params[:id]
#    ec2 = AWS::EC2.new
#    region = ec2.regions[@region]
#    unless region.exists?
#      redirect_to '/404.html' 
#    end
#    region.instances.each do |instance|
#      name = "BLANK"
#      instance.tags.each do |tag|
#        if tag[0] == "Name"
#          name = tag[1]
#          break
#        end
#      end
#      instance_data = {:name => name}
#      Account::INSTANCE_PARAMETERS.each do |parameter|
#        instance_data[parameter] = instance.send parameter
#      end
#      @instances << instance_data
#    end
#  end
end
