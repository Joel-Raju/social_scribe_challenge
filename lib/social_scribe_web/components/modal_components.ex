defmodule SocialScribeWeb.ModalComponents do
  @moduledoc """
  Reusable UI components for modals and dialogs.
  """
  use Phoenix.Component

  import SocialScribeWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders a searchable contact select box.

  Shows selected contact with avatar, or search input when no contact selected.
  Auto-searches when typing, dropdown shows results.

  ## Examples

      <.contact_select
        selected_contact={@selected_contact}
        contacts={@contacts}
        loading={@loading}
        open={@dropdown_open}
        query={@query}
        target={@myself}
      />
  """
  attr :selected_contact, :map, default: nil
  attr :contacts, :list, default: []
  attr :loading, :boolean, default: false
  attr :open, :boolean, default: false
  attr :query, :string, default: ""
  attr :target, :any, default: nil
  attr :error, :string, default: nil

  def contact_select(assigns) do
    ~H"""
    <div class="space-y-1">
      <label class="block text-sm font-medium text-slate-700">Select Contact</label>
      <div class="relative">
        <%= if @selected_contact do %>
          <button
            type="button"
            phx-click="toggle_contact_dropdown"
            phx-target={@target}
            class="relative w-full bg-white border border-slate-200 rounded-lg pl-3 pr-10 py-2.5 text-left cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
          >
            <span class="flex items-center">
              <.avatar firstname={@selected_contact.firstname} lastname={@selected_contact.lastname} size={:sm} />
              <span class="ml-3 block truncate text-slate-900">
                {@selected_contact.firstname} {@selected_contact.lastname}
              </span>
            </span>
            <span class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
              <.icon name="hero-chevron-up-down" class="h-5 w-5 text-gray-400" />
            </span>
          </button>
        <% else %>
          <div class="relative">
            <input
              type="text"
              name="contact_query"
              value={@query}
              placeholder="Search contacts..."
              phx-keyup="contact_search"
              phx-target={@target}
              phx-focus="open_contact_dropdown"
              phx-debounce="150"
              autocomplete="off"
              class="w-full bg-white border border-slate-200 rounded-lg pl-3 pr-10 py-2.5 text-left focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
            />
            <span class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
              <%= if @loading do %>
                <.icon name="hero-arrow-path" class="h-5 w-5 text-gray-400 animate-spin" />
              <% else %>
                <.icon name="hero-chevron-up-down" class="h-5 w-5 text-gray-400" />
              <% end %>
            </span>
          </div>
        <% end %>

        <div
          :if={@open && (Enum.any?(@contacts) || @loading || @query != "")}
          class="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm"
        >
          <div :if={@loading} class="px-4 py-2 text-sm text-gray-500">
            Searching...
          </div>
          <div :if={!@loading && Enum.empty?(@contacts) && @query != ""} class="px-4 py-2 text-sm text-gray-500">
            No contacts found
          </div>
          <button
            :for={contact <- @contacts}
            type="button"
            phx-click="select_contact"
            phx-value-id={contact.id}
            phx-target={@target}
            class="w-full text-left px-4 py-2 hover:bg-slate-50 flex items-center space-x-3 cursor-pointer"
          >
            <.avatar firstname={contact.firstname} lastname={contact.lastname} size={:sm} />
            <div>
              <div class="text-sm font-medium text-slate-900">
                {contact.firstname} {contact.lastname}
              </div>
              <div class="text-xs text-slate-500">
                {contact.email}
              </div>
            </div>
          </button>
        </div>
      </div>
      <.inline_error :if={@error} message={@error} />
    </div>
    """
  end

  @doc """
  Renders a search input with icon.

  ## Examples

      <.search_input
        name="query"
        value=""
        placeholder="Search..."
        loading={false}
      />
  """
  attr :name, :string, required: true
  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Search..."
  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  def search_input(assigns) do
    ~H"""
    <div class={["relative", @class]}>
      <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-400" />
      </div>
      <input
        type="text"
        name={@name}
        value={@value}
        class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        placeholder={@placeholder}
        {@rest}
      />
      <div :if={@loading} class="absolute inset-y-0 right-0 pr-3 flex items-center">
        <.icon name="hero-arrow-path" class="h-4 w-4 text-gray-400 animate-spin" />
      </div>
    </div>
    """
  end

  @doc """
  Renders an avatar with initials.

  ## Examples

      <.avatar firstname="John" lastname="Doe" size={:md} />
  """
  attr :firstname, :string, default: ""
  attr :lastname, :string, default: ""
  attr :size, :atom, default: :md, values: [:sm, :md, :lg]
  attr :class, :string, default: nil

  def avatar(assigns) do
    size_classes = %{
      sm: "h-6 w-6 text-xs",
      md: "h-8 w-8 text-xs",
      lg: "h-10 w-10 text-sm"
    }

    assigns = assign(assigns, :size_class, size_classes[assigns.size])

    ~H"""
    <div class={[
      "rounded-full bg-slate-200 flex items-center justify-center font-medium text-slate-600 flex-shrink-0",
      @size_class,
      @class
    ]}>
      {String.at(@firstname || "", 0)}{String.at(@lastname || "", 0)}
    </div>
    """
  end

  @doc """
  Renders a clickable contact list item.

  ## Examples

      <.contact_list_item
        contact={%{firstname: "John", lastname: "Doe", email: "john@example.com"}}
        on_click="select_contact"
        target={@myself}
      />
  """
  attr :contact, :map, required: true
  attr :on_click, :string, required: true
  attr :target, :any, default: nil
  attr :class, :string, default: nil

  def contact_list_item(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      phx-value-id={@contact.id}
      phx-target={@target}
      class={[
        "w-full px-4 py-3 text-left hover:bg-slate-50 transition-colors flex items-center space-x-3",
        @class
      ]}
    >
      <.avatar firstname={@contact.firstname} lastname={@contact.lastname} size={:md} />
      <div>
        <div class="text-sm font-medium text-slate-900">
          {@contact.firstname} {@contact.lastname}
        </div>
        <div class="text-xs text-slate-500">
          {@contact.email}
          <span :if={@contact[:company]} class="text-slate-400">· {@contact.company}</span>
        </div>
      </div>
    </button>
    """
  end

  @doc """
  Renders a contact list container.

  ## Examples

      <.contact_list>
        <.contact_list_item :for={c <- @contacts} contact={c} on_click="select" />
      </.contact_list>
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def contact_list(assigns) do
    ~H"""
    <div class={[
      "border border-gray-200 rounded-md divide-y divide-gray-200 max-h-64 overflow-y-auto bg-white shadow-sm",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a value comparison (old → new).

  ## Examples

      <.value_comparison
        current_value="old@email.com"
        new_value="new@email.com"
      />
  """
  attr :current_value, :string, default: nil
  attr :new_value, :string, required: true
  attr :class, :string, default: nil

  def value_comparison(assigns) do
    ~H"""
    <div class={["flex items-center space-x-4", @class]}>
      <div class="flex-1">
        <input
          type="text"
          readonly
          value={@current_value || ""}
          placeholder="No existing value"
          class="block w-full shadow-sm text-sm text-gray-400 bg-white border-gray-200 rounded-md py-2 px-3 line-through"
        />
      </div>
      <div class="text-gray-300">
        <.icon name="hero-arrow-long-right" class="h-6 w-6" />
      </div>
      <div class="flex-1">
        <input
          type="text"
          readonly
          value={@new_value}
          class="block w-full shadow-sm text-sm text-gray-900 border-gray-200 rounded-md py-2 px-3 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>
    </div>
    """
  end

  @doc """
  Renders a suggestion card with checkbox.

  ## Examples

      <.suggestion_card suggestion={%{field: "email", label: "Email", ...}} />
  """
  attr :suggestion, :map, required: true
  attr :class, :string, default: nil

  def suggestion_card(assigns) do
    ~H"""
    <div class={["bg-slate-50 border border-slate-200 rounded-xl p-5 mb-4 shadow-[0_1px_2px_rgba(0,0,0,0.04)]", @class]}>
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-3">
          <div class="flex items-center h-6">
            <input
              type="checkbox"
              name={"apply[#{@suggestion.field}]"}
              value={@suggestion.new_value}
              checked={@suggestion.apply}
              class="h-5 w-5 rounded border-gray-300 text-blue-600 focus:ring-blue-600 cursor-pointer"
            />
          </div>
          <label class="text-sm font-semibold text-gray-900">{@suggestion.label}</label>
        </div>

        <div class="flex items-center gap-4">
          <span :if={@suggestion.apply} class="inline-flex items-center rounded-full bg-gray-200 px-3 py-1 text-xs font-semibold text-gray-800">
            1 update selected
          </span>
          <button type="button" class="text-sm text-gray-400 hover:text-gray-600 font-medium">Hide details</button>
        </div>
      </div>

      <div class="ml-8">
        <div class="mt-3">
          <.value_comparison
            current_value={@suggestion.current_value}
            new_value={@suggestion.new_value}
          />
        </div>
        <div class="flex justify-between items-center pt-2">
          <button type="button" class="text-sm text-blue-600 hover:text-blue-700 font-medium">
            Update mapping
          </button>
          <span class="text-xs text-gray-500">
            Found in transcript
            <span :if={@suggestion[:context]} class="ml-1 text-blue-500 hover:underline cursor-help" title={@suggestion.context}>
              (hover for context)
            </span>
          </span>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a success message with checkmark icon.

  ## Examples

      <.success_message title="Success!" message="Operation completed." />
  """
  attr :title, :string, required: true
  attr :message, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block
  slot :actions

  def success_message(assigns) do
    ~H"""
    <div class={["text-center py-8", @class]}>
      <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100 mb-4">
        <.icon name="hero-check" class="h-6 w-6 text-green-600" />
      </div>
      <h3 class="text-lg font-medium text-slate-800 mb-2">{@title}</h3>
      <p :if={@message} class="text-slate-500 mb-6">{@message}</p>
      <div :if={@inner_block != []} class="text-slate-500 mb-6">
        {render_slot(@inner_block)}
      </div>
      <div :if={@actions != []}>
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  @doc """
  Renders a modal footer with cancel and submit buttons.

  ## Examples

      <.modal_footer
        cancel_url={~p"/dashboard"}
        submit_text="Save"
        loading={false}
      />
  """
  attr :cancel_patch, :string, default: nil
  attr :cancel_click, :any, default: nil
  attr :submit_text, :string, default: "Submit"
  attr :submit_class, :string, default: "bg-green-600 hover:bg-green-700"
  attr :loading, :boolean, default: false
  attr :loading_text, :string, default: "Processing..."
  attr :info_text, :string, default: nil
  attr :class, :string, default: nil

  def modal_footer(assigns) do
    ~H"""
    <div class={["pt-6 mt-6 border-t border-slate-200 flex items-center justify-between", @class]}>
      <div :if={@info_text} class="text-xs text-slate-500">
        {@info_text}
      </div>
      <div :if={!@info_text}></div>
      <div class="flex space-x-3">
        <button
          :if={@cancel_patch}
          type="button"
          phx-click={Phoenix.LiveView.JS.patch(@cancel_patch)}
          class="px-4 py-2 border border-slate-300 rounded-md shadow-sm text-sm font-medium text-slate-700 bg-white hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Cancel
        </button>
        <button
          :if={@cancel_click}
          type="button"
          phx-click={@cancel_click}
          class="px-4 py-2 border border-slate-300 rounded-md shadow-sm text-sm font-medium text-slate-700 bg-white hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={@loading}
          class={
            "px-4 py-2 rounded-md shadow-sm text-sm font-medium text-white " <>
              @submit_class <> " disabled:opacity-50"
          }
        >
          <span :if={@loading}>{@loading_text}</span>
          <span :if={!@loading}>{@submit_text}</span>
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Renders an empty state message.

  ## Examples

      <.empty_state title="No results" message="Try a different search." />
  """
  attr :title, :string, default: nil
  attr :message, :string, required: true
  attr :submessage, :string, default: nil
  attr :class, :string, default: nil

  def empty_state(assigns) do
    ~H"""
    <div class={["text-center py-8 text-slate-500", @class]}>
      <p :if={@title} class="font-medium text-slate-700 mb-1">{@title}</p>
      <p>{@message}</p>
      <p :if={@submessage} class="text-sm mt-2">{@submessage}</p>
    </div>
    """
  end

  @doc """
  Renders an error message.

  ## Examples

      <.inline_error :if={@error} message={@error} />
  """
  attr :message, :string, required: true
  attr :class, :string, default: nil

  def inline_error(assigns) do
    ~H"""
    <p class={["text-red-600 text-sm", @class]}>{@message}</p>
    """
  end
end
