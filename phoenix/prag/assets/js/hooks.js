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
            this.el, [78.2190991,15.6420511]
            // this.el, [39.74, -104.99]
        )
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
