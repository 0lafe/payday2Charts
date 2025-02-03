class UpdateUserJob
  include Sidekiq::Job

  def perform(*args)
    id = args[0].to_i
    limit = User.order('id DESC').limit(1).pluck(:id)[0]
    
    while !User.exists?(id)
      id += 1
      if id > limit
        UpdateUserJob.perform_async(1)
        return
      end
    end
    
    if id > limit
      UpdateUserJob.perform_async(1)
      return
    end

    begin
      User.find(id).fetch_new_stats
    rescue => exception
      
    end
    UpdateUserJob.perform_in(1.seconds, id + 1)
  end
end
