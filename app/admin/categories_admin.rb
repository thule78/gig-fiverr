Trestle.resource(:categories) do
  menu do
    item :categories, icon: "fa fa-star"
  end

  table do
    column :name
    column :active
    column :created_at, align: :center

    actions do |toolbar, instance, admin|
      toolbar.link 'Activate', admin.path(:activate, id: instance.id), method: :post, class: 'btn btn-primary'
      toolbar.link 'Deactivate', admin.path(:deactivate, id: instance.id), method: :post, class: 'btn btn-secondary'

    end
  end

  controller do
    def activate
      cat = admin.find_instance(params)
      cat.update(active: true)

      flash[:message] = "Category is activated"
      redirect_to admin.path(:show, id: cat)
    end

    def deactivate
      cat = admin.find_instance(params)
      cat.update(active: false)

      flash[:message] = 'Category is deactivated'
      redirect_to admin.path(:show, id: cat)
    end
  end

  routes do
    post :activate, on: :member
    post :deactivate, on: :member
  end

  form do |category|
    text_field :name
  end
end















