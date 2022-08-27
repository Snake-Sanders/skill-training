// date picker
import flatpickr from "../vendor/flatpickr"

// phone number formatter
import parsePhoneNumber from "../vendor/libphonenumber-min"

// container struct that has all the special hook functions
let Hooks = {};

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
