import flatpickr from "../vendor/flatpickr"

const DatePicker = {
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

export default DatePicker;
