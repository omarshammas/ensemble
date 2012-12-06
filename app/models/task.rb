class Task < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  before_create :set_interface

  attr_accessible :user_id, :body, :image, :finished, :interface
  
  belongs_to :user
  has_many :comments
  has_many :suggestions
  has_many :hits
  has_many :preferences
  
  has_attached_file :image, :styles => {:large => "500x500", :medium => "300x300", :small => "200x200>", :thumb => "100x100>" }


  def suggestion_sent?
    return !self.suggestions.where('sent = :sent AND accepted IS NULL',{:sent => true}).first.nil?
  end

  def set_interface
    self.interface = rand(2) == 0 ? 'first' : 'second'
  end
  
  
  def createHIT(base_url)
    @mturk = Amazon::WebServices::MechanicalTurkRequester.new
    
    title = "Make Fashion Recommendations"
    desc = "Help find clothing that matches someone's tastes."
    keywords = "fashion, recommendations"
    numAssignments = 1
    rewardAmount = 0.20 # 20 cents
   
    result = @mturk.createHIT( :Title => title,
      :Description => desc,
      :MaxAssignments => numAssignments,
      :Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
      :Question => get_question("#{base_url}turk/tasks/#{self.id.to_s}"),
      :Keywords => keywords )

    h = Hit.create task_id: self.id, h_id: result[:HITId], type_id:result[:HITTypeId], url: getHITUrl( result[:HITTypeId] )
    return h
  end

  def close
    self.update_attribute :finished, true
  end

private


  def get_question (task_url)
    '<?xml version="1.0" encoding="UTF-8"?>
      <QuestionForm xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd">
        <Question>
         <QuestionIdentifier>code</QuestionIdentifier>
         <QuestionContent>
           <FormattedContent><![CDATA[Work with other turkers to provide fashion recommendations.
              <p>When youre ready, go this this url:</p>
              <a href="'+task_url+'" target="_blank">'+task_url+'</a>
              <p>&nbsp;</p>
              <p>Enter your redeem code in the box below:</p>]]>
          </FormattedContent>
         </QuestionContent>
         <AnswerSpecification>
           <FreeTextAnswer/>
         </AnswerSpecification>
        </Question>
      </QuestionForm>'
  end

  def getHITUrl (hitTypeId)
    if @mturk.host =~ /sandbox/
      "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Sandbox Url
    else
      "http://mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Production Url
    end
  end

end
