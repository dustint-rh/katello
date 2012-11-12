module Authorization::ContentViewDefinition
  READ_PERM_VERBS = [:read, :create, :update, :delete, :publish]
  EDIT_PERM_VERBS = [:create, :update]

  def self.included(base)
    base.extend ClassMethods
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :content_view_definitions, self.id, self.organization)
  end

  def editable?
    User.allowed_to?(EDIT_PERM_VERBS, :content_view_definitions, self.id, self.organization)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :content_view_definitions, self.id, self.organization)
  end

  def publishable?
    User.allowed_to?([:publish], :content_view_definitions, self.id, self.organization)
  end

  module ClassMethods

    def tags(ids)
      select('id,name').where(:id => ids).collect do |m|
        VirtualTag.new(m.id, m.name)
      end
    end

    def list_tags(org_id)
      custom.select('id,name').where(:organization_id=>org_id).collect do |m|
        VirtualTag.new(m.id, m.name)
      end
    end

    def list_verbs(global = false)
      {
        :create  => _("Administer Content View Definitions"),
        :read    => _("Read Content View Definitions"),
        :update  => _("Modify Content View Defintions"),
        :delete  => _("Delete Content View Definitions"),
        :publish => _("Publish Content View Definitions")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      [:create]
    end

    def any_readable?(org)
      User.allowed_to?(READ_PERM_VERBS, :content_view_definitions, nil, org)
    end

    def readable(org)
      items(org, READ_PERM_VERBS)
    end

    def editable(org)
      items(org, EDIT_PERM_VERBS)
    end

    def creatable?(org)
      User.allowed_to?([:create], :providers, nil, org)
    end

    def items(org, verbs)
      raise "scope requires an organization" if org.nil?
      resource = :content_view_definitions
      if User.allowed_all_tags?(verbs, resource, org)
        where(:organization_id => org)
      else
        where("content_view_definitions.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
      end
    end

  end # end ClassMethods

end