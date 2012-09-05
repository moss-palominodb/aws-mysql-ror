module AwsHelper
  def wordize(words)
    words.split('_').collect { |w| w.capitalize }.join(' ')
  end
end
