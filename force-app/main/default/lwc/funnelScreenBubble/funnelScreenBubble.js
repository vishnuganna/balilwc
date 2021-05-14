import { LightningElement, api, track } from "lwc";
import chartjs from "@salesforce/resourceUrl/ChartJS";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import opportunityLabel from "@salesforce/label/c.OpportunitiesFunnel";
import errorLabel from "@salesforce/label/c.Error";
//import ErrorGettingData from "@salesforce/label/c.ErrorGettingData";

export default class FunnelScreenBubble extends LightningElement {
    @api chartConfig = [];
    @api stage;
    @track _chartConfig;
    @track chartConfiguration;
    @track yAxisOptyCount = 0 + " " + opportunityLabel;
    @track yAxisRevenue = "$ " + 0;
    @track showxAxis = false;
    @track bubbleColor;
    @track _stage;

    get stage() {
        return this._stage;
    }
    set stage(value) {
        this._stage = value;
        if (this.stage) {
            Promise.all([loadScript(this, chartjs)])
                .then(() => {
                    this.getConfigData();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: errorLabel,
                            message: error.message,
                            variant: "error"
                        })
                    );
                });
        }
    }

    connectedCallback() {
        // load chartjs from the static resource
    }

    convertRevenue(value) {
        // Nine Zeroes for Billions
        return Math.abs(Number(value)) >= 1.0e9
            ? (Math.abs(Number(value)) / 1.0e9).toFixed(2) + "B"
            : // Six Zeroes for Millions
            Math.abs(Number(value)) >= 1.0e6
            ? (Math.abs(Number(value)) / 1.0e6).toFixed(2) + "M"
            : // Three Zeroes for Thousands
            Math.abs(Number(value)) >= 1.0e3
            ? (Math.abs(Number(value)) / 1.0e3).toFixed(2) + "K"
            : Math.abs(Number(value));
    }

    getConfigData() {
        if (this.chartConfig && this.stage) {
            let datatoShow = [];
            let yAxisLabelData = [];
            let resArr = [];
            let stageValue;
            let arrayColors = [];

            stageValue = this.chartConfig.filter(obj => {
                return obj.label === this.stage;
            });
            if (stageValue) {
                stageValue.forEach(function(item) {
                    let i = resArr.findIndex(x => x.value[0].opportunityStage === item.value[0].opportunityStage);
                    if (i <= -1) {
                        resArr.push(item);
                    }
                });
                yAxisLabelData.push(this.stage);
                resArr.forEach(element => {
                    if (yAxisLabelData.includes(element.value[0].opportunityStage)) {
                        let array = [
                            element.value[0].opportunityStage,
                            element.value[0].countOptyPerStage + " " + opportunityLabel,
                            "$ " + element.value[0].optyRevenuePerStage
                        ];
                        this.yAxisOptyCount = element.value[0].countOptyPerStage + " " + opportunityLabel;
                        let convertedRevenue = this.convertRevenue(element.value[0].optyRevenuePerStage);
                        //this.yAxisRevenue = "$ " + element.value[0].optyRevenuePerStage;
                        this.yAxisRevenue = "$ " + convertedRevenue;
                        yAxisLabelData[
                            yAxisLabelData
                                .map((x, i) => [i, x])
                                .filter(x => x[1] === element.value[0].opportunityStage)[0][0]
                        ] = array.join(",");
                    }
                });
                stageValue.forEach(element => {
                    if (element.label === this.stage) {
                        let yAxisPoint = [];
                        for (let i = 0; i < yAxisLabelData.length; i++) {
                            if (yAxisLabelData[i].includes(element.value[0].opportunityStage)) {
                                yAxisPoint = yAxisLabelData[i];
                            }
                        }
                        let childValue = element.value;
                        for (let i = 0; i < childValue.length; i++) {
                            //console.log('element.value[i]--- >>>> '+JSON.stringify(element.value[i]));
                            if (!element.value[i].isConnectedToBluesheet) {
                                this.bubbleColor = "#383838";
                            } else {
                                this.bubbleColor = "#4973AB";
                            }

                            let array = {
                                x: element.value[i].scorecardTotalScore,
                                y: yAxisPoint,
                                r: element.value[i].opportunityRadius,
                                label: element.value[i].optyName
                            };
                            datatoShow.push(array);
                            arrayColors.push(this.bubbleColor);
                        }
                    }
                });
            }

            this.chartConfiguration = {
                type: "bubble",
                data: {
                    datasets: [
                        {
                            //label: "Days in Stage",
                            data: datatoShow,
                            borderColor: arrayColors,
                            fill: true,
                            backgroundColor: arrayColors
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        display: false,
                        position: "right",
                        align: "right"
                    },
                    layout: {
                        padding: {
                            top: 35,
                            left: 35,
                            right: 25,
                            bottom: 85
                        },
                        backgroundColor: "pink"
                    },
                    scales: {
                        yAxes: [
                            {
                                type: "category",
                                // labels: yAxisLabelData,
                                position: "left",
                                backgroundColor: "green",
                                fontSize: 15,
                                ticks: {
                                    stepSize: 1
                                    // padding: 35,
                                },
                                gridLines: {
                                    display: false
                                },
                                display: false
                                // margins: {
                                //     left: 150
                                // },
                            }
                        ],
                        xAxes: [
                            {
                                gridLines: {
                                    display: false
                                },
                                backgroundColor: "red",
                                display: this.showxAxis,
                                ticks: {
                                    beginAtZero: true,
                                    min: 0,
                                    max: 100,
                                    stepSize: 20
                                },
                                scaleLabel: { display: true, labelString: "Scorecard Score" }
                            }
                        ]
                    },
                    chartArea: {
                        backgroundColor: "rgba(251, 85, 85, 0.4)"
                    },
                    tooltips: {
                        mode: "index",
                        callbacks: {
                            title: function() {
                                return "***** My opty name *****";
                            }
                        },
                        backgroundColor: "white",
                        bodyFontColor: "black",
                        bodyAlign: "center",
                        yAlign: "bottom"
                    }
                }
            };
            const ctx = this.template.querySelector("canvas.bubbleChart").getContext("2d");
            this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfiguration)));
            this.error = undefined;
        }
    }
}