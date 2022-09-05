// import Chart from "chart.js";
import Chart from "../vendor/chart.min";

class LineChart {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Customer 1",
            data: values,
            borderColor: "#4c51bf",
            borderWidth: 2
          },
        ],
      },
      options: {
        scales: {
          x: {
            display: true,
            type: 'linear',
            title: {
              display: true,
              text: 'Measurements'
            }
          },
          y: {
            display: true,
            type: 'linear',
            title: {
              display: true,
              text: 'Sugar levels'
            },
            suggestedMin: 0,
            suggestedMax: 200
          }
        },
      },
    });
  }

  addPoint(label, value) {
    const labels = this.chart.data.labels;
    const data = this.chart.data.datasets[0].data;

    labels.push(label);
    data.push(value);

    if (data.length > 12) {
      data.shift();
      labels.shift();
    }

    this.chart.update("none");
  }
}

export default LineChart;
