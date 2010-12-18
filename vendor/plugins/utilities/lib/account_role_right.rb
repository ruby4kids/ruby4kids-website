# This Module is included into the User Class to extend it to support Roles and Rights data

module AccountRoleRight
  
  def rights # Return the Rights for this Account
    if(@rights == nil) then set_rights end
    return @rights
  end

  def has_right(name)
    if(@rights == nil) then set_rights end
    if @rights.detect{|r| r==name} != nil then true else false end
  end
  
  def has_role?(name)
    self.roles.any? {|x| x.name == name}
  end
  
  private
  def set_rights
    @rights = self.roles.collect{|x| x.rights}.flatten!.collect{|x| x.name}.uniq rescue [] 
  end


end
