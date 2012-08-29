class AwsController < ApplicationController
  require 'net/http'
  require 'net/ssh'

  def regions
    ec2 = AWS::EC2.new
    @regions = ec2.regions.map(&:name)
  end

  def region
    @region = params[:id]
    ec2 = AWS::EC2.new
    region = ec2.regions[@region]
    unless region.exists?
      redirect_to '/404.html' 
    end
    @instances = []
    region.instances.each do |instance|
      name = "BLANK"
      instance.tags.each do |tag|
        if tag[0] == "Name"
          name = tag[1]
          break
        end
      end
      @instances << {:name => name,
                     :id => instance.id,
                     :status => instance.status}
    end
  end
end
