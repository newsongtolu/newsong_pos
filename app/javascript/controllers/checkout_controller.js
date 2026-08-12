import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const urlParams = new URLSearchParams(window.location.search)
    let orderId = urlParams.get("order_id") || urlParams.get("order") || urlParams.get("id") || localStorage.getItem("active_order_id")
    
    if (orderId) {
      localStorage.setItem("active_order_id", orderId)
      
      if (!urlParams.get("order_id") && !urlParams.get("order") && !urlParams.get("id")) {
        const newUrl = new URL(window.location.href)
        newUrl.searchParams.set("order_id", orderId)
        window.history.replaceState({}, '', newUrl)
      }
      
      const entryGates = document.querySelectorAll(
        "#splash-screen, #service-gate-modal, .service-gate, [id*='service-gate'], [class*='service-gate']"
      )
      entryGates.forEach(el => {
        el.style.display = "none"
        el.classList.add("hidden")
      })
    }

    // --- RESTORE VISUAL CART ITEMS ON REFRESH ---
    let cartItems = []
    const amendmentKey = orderId ? `amendment_cart_${orderId}` : null
    if (amendmentKey && localStorage.getItem(amendmentKey)) {
      try {
        cartItems = JSON.parse(localStorage.getItem(amendmentKey))
      } catch (err) {}
    }
    if (cartItems.length === 0) {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i)
        const val = localStorage.getItem(key)
        if (key && (key.toLowerCase().includes("cart") || key.toLowerCase().includes("menu") || key.toLowerCase().includes("pos"))) {
          try {
            const parsed = JSON.parse(val)
            if (Array.isArray(parsed) && parsed.length > 0) {
              cartItems = parsed
              break
            }
          } catch (err) {}
        }
      }
    }

    // If we found saved cart items, automatically render them into the cart UI container
    if (cartItems.length > 0) {
      const cartContainer = document.querySelector(".cart-items-list, #cart-items-list, [data-cart-items]")
      const emptyMsg = document.querySelector("#cart-empty-msg, .cart-empty")
      if (cartContainer) {
        if (emptyMsg) emptyMsg.style.display = "none"
        
        // Only inject if container is currently empty to avoid duplication
        if (!cartContainer.hasChildNodes() || cartContainer.children.length === 0) {
          cartItems.forEach(item => {
            const row = document.createElement("div")
            row.className = "cart-container-row"
            row.innerHTML = `
              <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                <span>${item.name || item.title || "Item"} (x${item.quantity || item.qty || 1})</span>
                <span>₦${((item.price || item.amount || 0) * (item.quantity || item.qty || 1)).toLocaleString()}</span>
              </div>
            `
            cartContainer.appendChild(row)
          })
        }
      }
      
      // Update badge counts if they exist
      const badge = document.querySelector("#header-cart-count, .cart-counter-badge")
      if (badge) {
        const totalQty = cartItems.reduce((sum, i) => sum + (parseInt(i.quantity || i.qty || 1)), 0)
        badge.textContent = totalQty
      }
    }
    // -------------------------------------------

    const form = this.element.querySelector("form")
    if (form) {
      const formFulfillment = form.dataset.fulfillmentType || form.dataset.serviceMode || 
                              document.querySelector("[data-order-fulfillment]")?.dataset.orderFulfillment ||
                              document.querySelector("input[name*='fulfillment_type']")?.value || localStorage.getItem("pos_fulfillment_mode") || "takeaway"
      if (formFulfillment) {
        localStorage.setItem("pos_fulfillment_mode", formFulfillment)
        localStorage.setItem("active_order_fulfillment", formFulfillment)
        localStorage.setItem("fulfillment", formFulfillment)
        localStorage.setItem("service_mode", formFulfillment)
        localStorage.setItem("order_type", formFulfillment)
      }

      const savedDraft = localStorage.getItem("pos_form_draft")
      if (savedDraft) {
        try {
          const draftData = JSON.parse(savedDraft)
          Object.keys(draftData).forEach(key => {
            const input = form.querySelector(`[name="${key}"]`)
            if (input && !input.value) {
              input.value = draftData[key]
            }
          })
        } catch (err) {}
      }

      if (!form.dataset.draftListenerAttached) {
        form.dataset.draftListenerAttached = "true"
        const saveDraft = () => {
          const formData = {}
          new FormData(form).forEach((val, key) => {
            formData[key] = val
          })
          localStorage.setItem("pos_form_draft", JSON.stringify(formData))
        }
        form.addEventListener("input", saveDraft)
        form.addEventListener("change", saveDraft)
      }

      if (!form.dataset.cartListenerAttached) {
        form.dataset.cartListenerAttached = "true"
        
        form.addEventListener("submit", (e) => {
          const paymentMethodInput = form.querySelector("input[name*='payment_method']:checked, select[name*='payment_method'], [data-payment-method].selected")
          const selectedPayment = paymentMethodInput ? (paymentMethodInput.value || paymentMethodInput.dataset.paymentMethod) : null
          
          if (selectedPayment && selectedPayment.toLowerCase().includes("paystack")) {
            const dynamicPaystackUrl = window.APP_PAYSTACK_LINK || form.dataset.paystackLink
            if (dynamicPaystackUrl) {
              e.preventDefault()
              window.location.href = dynamicPaystackUrl
              return
            }
          }

          form.querySelectorAll("input.dynamic-cart-item").forEach(el => el.remove())
          cartItems.forEach((item, index) => {
            const createInput = (name, value) => {
              const input = document.createElement("input")
              input.type = "hidden"
              input.name = `order[order_items_attributes][new_${index}][${name}]`
              input.value = value
              input.className = "dynamic-cart-item"
              form.appendChild(input)
            }
            createInput("menu_item_id", item.id || item.menu_item_id || item.itemId)
            createInput("name", item.name || item.title || "")
            createInput("price", item.price || item.amount || 0)
            createInput("quantity", item.quantity || item.qty || 1)
          })

          if (amendmentKey) {
            localStorage.removeItem(amendmentKey)
          }
          localStorage.removeItem("active_order_id")
          localStorage.removeItem("pos_form_draft")
        })
      }
    }
  }
}