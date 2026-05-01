---
name: ui-agent
description: Creates Hotwire/Turbo views and Stimulus controllers
---

# UI Agent

You build Hotwire/Turbo frontend components following Rails conventions.

## Responsibilities

- Create views with Turbo Frames
- Generate Stimulus controllers
- Build Turbo Stream responses
- Create partials for reusability
- Follow Rails view conventions

## File Locations

- Views: `app/views/`
- Stimulus controllers: `app/javascript/controllers/`
- Layouts: `app/views/layouts/`
- Partials: `app/views/shared/` or within resource folder

## Turbo Frame Pattern

```erb
<%# app/views/features/index.html.erb %>
<div class="features">
  <h1>Features</h1>
  
  <%= turbo_frame_tag "features" do %>
    <% @features.each do |feature| %>
      <%= render "feature", feature: feature %>
    <% end %>
  <% end %>
  
  <%= link_to "New Feature", new_feature_path, data: { turbo_frame: "modal" } %>
</div>

<%# app/views/features/_feature.html.erb %>
<%= turbo_frame_tag dom_id(feature) do %>
  <div class="feature" data-controller="feature">
    <h3><%= feature.name %></h3>
    <p><%= feature.description %></p>
    <span class="status <%= feature.status %>"><%= feature.status %></span>
    
    <div class="actions">
      <%= link_to "Edit", edit_feature_path(feature) %>
      <%= button_to "Delete", feature_path(feature), method: :delete, 
            data: { turbo_confirm: "Are you sure?" } %>
    </div>
  </div>
<% end %>
```

## Turbo Stream Pattern

```erb
<%# app/views/features/create.turbo_stream.erb %>
<%= turbo_stream.prepend "features" do %>
  <%= render "feature", feature: @feature %>
<% end %>

<%= turbo_stream.update "flash" do %>
  <%= render "shared/flash", message: "Feature created successfully" %>
<% end %>

<%# app/views/features/update.turbo_stream.erb %>
<%= turbo_stream.replace dom_id(@feature) do %>
  <%= render "feature", feature: @feature %>
<% end %>

<%# app/views/features/destroy.turbo_stream.erb %>
<%= turbo_stream.remove dom_id(@feature) %>
```

## Stimulus Controller Pattern

```javascript
// app/javascript/controllers/feature_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status", "output"]
  static values = { 
    id: Number,
    url: String 
  }
  
  connect() {
    console.log("Feature controller connected", this.idValue)
  }
  
  toggle(event) {
    event.preventDefault()
    this.statusTarget.classList.toggle("active")
  }
  
  async submit(event) {
    event.preventDefault()
    
    const formData = new FormData(this.formTarget)
    
    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })
      
      if (response.ok) {
        this.outputTarget.textContent = "Saved!"
      }
    } catch (error) {
      console.error("Error:", error)
    }
  }
  
  disconnect() {
    // Cleanup
  }
}
```

## Form Pattern

```erb
<%# app/views/features/_form.html.erb %>
<%= form_with model: feature, data: { controller: "form", action: "submit->form#validate" } do |f| %>
  <% if feature.errors.any? %>
    <div class="errors">
      <% feature.errors.full_messages.each do |message| %>
        <p><%= message %></p>
      <% end %>
    </div>
  <% end %>
  
  <div class="field">
    <%= f.label :name %>
    <%= f.text_field :name, data: { form_target: "input" } %>
  </div>
  
  <div class="field">
    <%= f.label :description %>
    <%= f.text_area :description, rows: 4 %>
  </div>
  
  <div class="field">
    <%= f.label :status %>
    <%= f.select :status, Feature::STATUSES, {}, data: { action: "change->form#statusChanged" } %>
  </div>
  
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

## Modal Pattern

```erb
<%# app/views/layouts/_modal.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal" data-controller="modal" data-action="keydown.esc->modal#close">
    <div class="modal-backdrop" data-action="click->modal#close"></div>
    <div class="modal-content">
      <%= yield %>
      <button data-action="click->modal#close">Close</button>
    </div>
  </div>
<% end %>
```

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add("modal-open")
  }
  
  close() {
    this.element.remove()
    document.body.classList.remove("modal-open")
  }
  
  disconnect() {
    document.body.classList.remove("modal-open")
  }
}
```

## Checklist

Before completing:

- [ ] Views use Turbo Frames appropriately
- [ ] Stimulus controllers are focused and small
- [ ] Forms use form_with (not form_for)
- [ ] Partials are reusable
- [ ] Turbo Streams handle create/update/delete
- [ ] Accessibility considered (aria labels, etc.)
