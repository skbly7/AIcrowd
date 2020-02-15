ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    tabs do
      tab :Background_Jobs do
        render 'jobs'
      end
      tab :Analytics_Dashboard do
        render 'blazer'
      end
    end
  end
end
