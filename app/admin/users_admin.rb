Trestle.resource(:users) do
  remove_action :destroy

  menu do
    item :users, icon: "fa fa-user"
  end

end
