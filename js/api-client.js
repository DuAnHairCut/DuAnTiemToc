// Hair Studio API Client
class HairStudioAPI {
  constructor() {
    this.baseURL = "http://127.0.0.1:8000/api";
  }

  // Helper method for API calls
  async apiCall(endpoint, method = "GET", data = null) {
    const url = `${this.baseURL}${endpoint}`;
    const options = {
      method: method,
      headers: {
        "Content-Type": "application/json",
      },
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    try {
      const response = await fetch(url, options);
      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.detail || "API call failed");
      }

      return result;
    } catch (error) {
      console.error("API Error:", error);
      throw error;
    }
  }

  // Get all services
  async getServices() {
    return await this.apiCall("/services");
  }

  // Get single service
  async getService(serviceId) {
    return await this.apiCall(`/services/${serviceId}`);
  }

  // Create booking
  async createBooking(bookingData) {
    return await this.apiCall("/bookings", "POST", bookingData);
  }

  // Send contact form
  async sendContact(contactData) {
    return await this.apiCall("/contact", "POST", contactData);
  }

  // Get available times for a date
  async getAvailableTimes(date) {
    return await this.apiCall(`/available-times?date=${date}`);
  }
}

// Initialize API client
const api = new HairStudioAPI();

// DOM Content Loaded
document.addEventListener("DOMContentLoaded", function () {
  // Load services on homepage
  if (document.querySelector(".ftco-services")) {
    loadServices();
  }

  // Setup booking form
  const bookingForm = document.getElementById("appointment-form");
  if (bookingForm) {
    setupBookingForm();
  }

  // Setup contact form
  const contactForm = document.getElementById("contact-form");
  if (contactForm) {
    setupContactForm();
  }
});

// Load services and display them
async function loadServices() {
  try {
    const services = await api.getServices();
    displayServices(services);
  } catch (error) {
    console.error("Error loading services:", error);
  }
}

// Display services in the DOM
function displayServices(services) {
  const servicesContainer = document.querySelector(
    ".ftco-services .container .row"
  );
  if (!servicesContainer) return;

  servicesContainer.innerHTML = "";

  services.forEach((service) => {
    const serviceHTML = `
            <div class="col-md-3 d-flex align-self-stretch ftco-animate">
                <div class="media block-6 services d-block text-center">
                    <div class="icon d-flex justify-content-center align-items-center">
                        <span class="flaticon-scissors"></span>
                    </div>
                    <div class="media-body p-2 mt-3">
                        <h3 class="heading">${service.name}</h3>
                        <p>${service.description}</p>
                        <p class="price"><span>${formatPrice(
                          service.price
                        )}</span></p>
                        <p class="duration">Thời gian: ${
                          service.duration
                        } phút</p>
                        <button class="btn btn-primary" onclick="bookService(${
                          service.id
                        })">Đặt Lịch</button>
                    </div>
                </div>
            </div>
        `;
    servicesContainer.innerHTML += serviceHTML;
  });
}

// Format price in Vietnamese currency
function formatPrice(price) {
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
  }).format(price);
}

// Book a service
function bookService(serviceId) {
  // Store selected service and redirect to booking page
  localStorage.setItem("selectedServiceId", serviceId);
  window.location.href = "contact.html#booking";
}

// Setup booking form
function setupBookingForm() {
  const form = document.getElementById("appointment-form");
  const serviceSelect = document.getElementById("service-select");
  const dateInput = document.getElementById("date-input");
  const timeSelect = document.getElementById("time-select");

  // Load services into select
  loadServicesIntoSelect();

  // Handle date change to load available times
  if (dateInput) {
    dateInput.addEventListener("change", loadAvailableTimes);
  }

  // Handle form submission
  if (form) {
    form.addEventListener("submit", handleBookingSubmit);
  }
}

// Load services into select dropdown
async function loadServicesIntoSelect() {
  try {
    const services = await api.getServices();
    const serviceSelect = document.getElementById("service-select");

    if (serviceSelect) {
      serviceSelect.innerHTML = '<option value="">Chọn dịch vụ</option>';
      services.forEach((service) => {
        serviceSelect.innerHTML += `
                    <option value="${service.id}">
                        ${service.name} - ${formatPrice(service.price)}
                    </option>
                `;
      });

      // Auto-select service if coming from service page
      const selectedServiceId = localStorage.getItem("selectedServiceId");
      if (selectedServiceId) {
        serviceSelect.value = selectedServiceId;
        localStorage.removeItem("selectedServiceId");
      }
    }
  } catch (error) {
    console.error("Error loading services:", error);
  }
}

// Load available times for selected date
async function loadAvailableTimes() {
  const dateInput = document.getElementById("date-input");
  const timeSelect = document.getElementById("time-select");

  if (!dateInput || !timeSelect || !dateInput.value) return;

  try {
    const result = await api.getAvailableTimes(dateInput.value);
    timeSelect.innerHTML = '<option value="">Chọn giờ</option>';

    result.available_times.forEach((time) => {
      timeSelect.innerHTML += `<option value="${time}">${time}</option>`;
    });
  } catch (error) {
    console.error("Error loading available times:", error);
  }
}

// Handle booking form submission
async function handleBookingSubmit(e) {
  e.preventDefault();

  const formData = new FormData(e.target);
  const bookingData = {
    name: formData.get("name"),
    phone: formData.get("phone"),
    email: formData.get("email"),
    service_id: parseInt(formData.get("service")),
    date: formData.get("date"),
    time: formData.get("time"),
    message: formData.get("message"),
  };

  try {
    const result = await api.createBooking(bookingData);

    // Show success message
    showAlert("success", result.message);
    e.target.reset();
  } catch (error) {
    showAlert("error", "Có lỗi xảy ra: " + error.message);
  }
}

// Setup contact form
function setupContactForm() {
  const form = document.getElementById("contact-form");
  if (form) {
    form.addEventListener("submit", handleContactSubmit);
  }
}

// Handle contact form submission
async function handleContactSubmit(e) {
  e.preventDefault();

  const formData = new FormData(e.target);
  const contactData = {
    name: formData.get("name"),
    email: formData.get("email"),
    subject: formData.get("subject"),
    message: formData.get("message"),
  };

  try {
    const result = await api.sendContact(contactData);

    // Show success message
    showAlert("success", result.message);
    e.target.reset();
  } catch (error) {
    showAlert("error", "Có lỗi xảy ra: " + error.message);
  }
}

// Show alert messages
function showAlert(type, message) {
  // Remove existing alerts
  const existingAlert = document.querySelector(".custom-alert");
  if (existingAlert) {
    existingAlert.remove();
  }

  // Create alert
  const alert = document.createElement("div");
  alert.className = `custom-alert alert-${type}`;
  alert.innerHTML = `
        <div class="alert-content">
            <span class="alert-icon">${type === "success" ? "✓" : "⚠"}</span>
            <span class="alert-message">${message}</span>
            <button class="alert-close" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;

  // Add styles
  alert.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        font-family: 'Poppins', sans-serif;
        font-weight: 500;
        background: ${type === "success" ? "#28a745" : "#dc3545"};
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        animation: slideIn 0.3s ease;
    `;

  document.body.appendChild(alert);

  // Auto remove after 5 seconds
  setTimeout(() => {
    if (alert.parentElement) {
      alert.remove();
    }
  }, 5000);
}

// Add CSS for animations
const style = document.createElement("style");
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    .alert-content {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .alert-close {
        background: none;
        border: none;
        color: white;
        font-size: 18px;
        cursor: pointer;
        margin-left: 10px;
    }
`;
document.head.appendChild(style);
