class StatsController < ApplicationController
  def show
    render json: {data: generate_data(params[:id])}
  end

  private

  def generate_data(type)
    stats = get_stats(generate_url(type), (Date.today - 59.days).to_time.to_i, Date.today.to_time.to_i)
    data = []
    no_history = []
    stats['response']['globalstats'].each do |stat|
      history, labels = if stat[1]['history']
        [
          stat[1]['history'].map {|history_item| history_item['total'] },
          stat[1]['history'].map {|history_item| Time.at(history_item['date']).to_date.to_s }
        ]
      else
        [
          [stat[1]['total']],
          ['Total']
        ]
      end
      item = {
        name: stat[0],
        value: history,
        localized_name: Localizer.localize_from_statistic(stat[0]),
        labels: labels,
        item_name: Localizer.remove_stat(stat[0]),
        img_url: Localizer.generate_image_url(stat[0]),
      }
      if stat[1]['history']
        data << item
      else
        no_history << item
      end
    end
    data = data.sort_by {|stat| stat[:value].reduce(0) {|sum, i| sum + i.to_i } }.reverse
    no_history = no_history.sort_by {|stat| stat[:value].reduce(0) {|sum, i| sum + i.to_i } }.reverse
    data.concat(no_history)
    data
  end
end