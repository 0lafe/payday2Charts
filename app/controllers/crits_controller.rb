class CritsController < ApplicationController
  def index
  end

  def calculate
    if check_params
      begin
        cc = CritCalculator.new(crit_params)
        result = cc.check_crit(params[:crit_chance].to_f)
        @shots = result[:shots].round(2)
        distribution = result[:distribution]
        @labels = distribution.map {|i| i[0] }
        @values = distribution.map {|i| i[1] }
      rescue => error
        @error = error
        byebug
      end
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('crit_calculator_result', partial: 'crits/calculate'),
          turbo_stream.replace('crit_chart', partial: 'crits/crit_chart')
        ]
      end
    end
  end

  private

  def crit_params
    params.permit(:base_weapon_damage, :headshot_mul, :additional_mul, :enemy_health, :crit_mul, :crit_chance)
  end

  def check_params
    values = crit_params.to_h
    values.delete('headshot_mul')
    values.delete('additional_mul')
    values.values.reduce(true) do |acc, param|
      if acc
        byebug if !param.length.positive?
        param.length.positive?
      else
        false
      end
    end
  end
end
