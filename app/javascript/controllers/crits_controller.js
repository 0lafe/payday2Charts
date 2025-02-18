import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

// Connects to data-controller="crits"
export default class extends Controller {
  connect() {
    $("#calculate").on("click", (e) => {
      e.preventDefault()
      this.calculate()
    })
  }
  
  async calculate() {
    await this.setVals()
    this.checkCrit()
    this.renderChart(
      this.distribution.map(item => item[0]),
      this.distribution.map(item => item[1])
    )
    $("#calculation_values").text(
      `Average ${parseFloat(this.shots).toFixed(3)} shots`
    )
  }

  async setVals() {
    const base_damage = Number($("#calculation_base_weapon_damage").val())
    const headshot_mul = Number($("#calculation_headshot_mul").val()) || 1
    const additional_mul = Number($("#calculation_additional_mul").val()) || 1
    this.damage = base_damage * headshot_mul * additional_mul
    this.critChance = Number($("#calculation_crit_chance").val()) / 100
    this.critMul = Number($("#calculation_crit_mul").val())
    this.enemyHealth = Number($("#calculation_enemy_health").val())
    this.maxShots = Math.ceil(this.enemyHealth / this.damage)
    
    const reply = await fetch("/assets/factorials.json")
    const response = await reply.json()
    this.factorials = response

    Chart.register(...registerables);
  }

  factorial(num) {
    return this.factorials[num - 1] || 1
  }

  combinationCalc(c, h) {
    h = Math.max(h, 0)
    return this.factorial(c + h) / (this.factorial(c) * this.factorial(h))
  }

  checkCrit() {
    let crits = 0
    let carry = 0
    let shots = 0
    let hits = this.maxShots - 1

    this.distribution = []

    while (hits >= 0) {
      const currentShots = crits + hits + 1
      let count = this.combinationCalc(crits, hits)
      let c_count = crits + 1
      let scaledProbability = count * this.critChance ** (c_count) * (1.0 - this.critChance) ** (hits)

      if (carry == 0 && hits > 0) {
        count = this.combinationCalc(crits, hits + 1)
        scaledProbability += count * this.critChance ** (crits) * (1.0 - this.critChance) ** (hits + 1)
      }

      if (carry == 0 && hits == 0 && (this.enemyHealth - this.damage * this.critMul * (c_count - 1)) <= this.damage) {
        count = this.combinationCalc(crits, 1)
        scaledProbability += count * this.critChance ** (crits) * (1.0 - this.critChance)
      }

      shots += scaledProbability * currentShots

      this.distribution.push([currentShots, scaledProbability])
 
      hits--
      carry++

      if (carry == (this.critMul - 1)) {
        carry = 0
        if (hits > 0) {
          crits += 1
          hits -= 1
        }
      }
    }
    this.shots = shots
  }

  renderChart(labels, values) {
    const ctx = document.getElementById(`calculation_chart`);
  
    if (this.chart) {
      this.chart.destroy()
    }

    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Shot Distribution',
          data: values,
          borderWidth: 1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true,
            max: Math.max(...values),
            min: 0
          },
          x: {
            
          }
        }
      }
    });
  }
}
