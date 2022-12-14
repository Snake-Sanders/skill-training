// date picker
import flatpickr from "../vendor/flatpickr"

// phone number formatter
import parsePhoneNumber from "../vendor/libphonenumber-min"

import LineChart from "./line-chart"

import IncidentMap from "./incident-map"

// container struct that has all the special hook functions
let Hooks = {};

Hooks.IncidentMap = {
    mounted() {
        console.log("IncidentMap mounted");
        this.map = new IncidentMap(
            this.el, [39.74, -104.99], event => {
                const incidentId = event.target.options.incidentId;
                this.pushEvent("marker-clicked", incidentId, (reply, ref) => {
                    this.scrollTo(reply.incident.id);
                });
            }
        )
        // the incidents are no longer passed by dataset.
        // const incidents = JSON.parse(this.el.dataset.incidents);
        // incidents.forEach(incident => {
        //     this.map.addMarker(incident);
        // })

        // now the client request the incidents to the server
        this.pushEvent("get-incidents", {}, (reply, ref) => {
            reply.incidents.forEach(incident => {
                this.map.addMarker(incident)
            })
        })

        this.handleEvent("highlight-marker", incident => {
            this.map.highlightMarker(incident)
        })

        this.handleEvent("add-marker", incident => {
            this.map.addMarker(incident);
            this.map.highlightMarker(incident);
            this.scrollTo(incident.id)
        })
    },

    scrollTo(incidentId){
        const incidetElement = 
            document.querySelector(`[phx-value-id="${incidentId}"]`);
        incidetElement.scrollIntoView(false);
    }
}

Hooks.LineChart = {
    mounted() {
        console.log("LineChart mounted");
        const {labels, values} =JSON.parse(this.el.dataset.chartData);
        this.chart = new LineChart(this.el, labels, values) 

        // connects and handle the event `new-point` triggered by chart_live.ex
        this.handleEvent("new-point", ({label, value}) => {
            this.chart.addPoint(label, value)
        })
    }
}

Hooks.DatePicker = {
    mounted() {
        console.log("DatePicker mounted");
        flatpickr(this.el, {
            enableTime: false,
            dateFormat: "F d, Y",
            onChange: this.handleDatePicked.bind(this),
        });
    },

    handleDatePicked(selectedDates, dateStr, instance) {
        // send the dateStr to the LiveView
        console.log("DatePicker selected");
        this.pushEvent("dates-picked", dateStr)
    }
};

// detects when the page reaches the footer and then this function
// request more items to be displayed as continuation of the page.
Hooks.InfiniteScroll = {
    mounted() {
        console.log("Footer added to DOM!", this.el);
        this.observer = new IntersectionObserver(entries => {
            const entry = entries[0];
            if (entry.isIntersecting) {
                console.log("Footer is visible!");
                this.pushEvent("load-more");
            }
        });

        this.observer.observe(this.el);
    },
    updated() {
        const pageNumber = this.el.dataset.pageNumber;
        console.log("updated", pageNumber);
    },
    destroyed() {
        this.observer.disconnect();
    },
};

Hooks.PhoneFormatter = {
    mounted() {
        console.log("Phone Formatter mounted!", this.el);
        console.log(this.el.value);
        this.el.addEventListener("input", e => {
            const phoneNumber = parsePhoneNumber(this.el.value, 'US')
            if (phoneNumber) {
                this.el.value = phoneNumber.formatNational()
                console.log(this.el.value)
            }
        });
    }
}

export default Hooks;
