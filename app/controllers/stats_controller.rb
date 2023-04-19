class StatsController < ApplicationController
  def show
    render json: {data: generate_data(params[:id])}
  end

  private

  def generate_data(type)
    stats = get_stats(generate_url(type), (Date.today - 59.days).to_time.to_i, Date.today.to_time.to_i)
    data = stats['response']['globalstats'].map do |stat|
      history, labels = if stat[1]['history']
        [
          stat[1]['history'].map {|history_item| history_item['total'] },
          stat[1]['history'].map {|history_item| Time.at(history_item['date']).to_date.to_s }
        ]
      else
        [
          [stat[1]['total'], stat[1]['total']],
          [Date.today.to_date.to_s, Date.today.to_date.to_s]
        ]
      end
      {
        name: stat[0],
        value: history,
        localized_name: Localizer.localize_from_statistic(stat[0]),
        labels: labels,
        item_name: Localizer.remove_stat(stat[0]),
        img_url: Localizer.generate_image_url(stat[0])
      }
    end
    data.sort_by {|stat| stat[:value].reduce(0) {|sum, i| sum + i.to_i } }.reverse
  end
end