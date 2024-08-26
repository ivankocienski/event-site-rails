module PartnersHelper
  def partner_contact_info(partner)
    contact = partner.contact

    parts = []
    parts << link_to(contact.email, "mailto:#{contact.email}") if contact.email.present?
    parts << link_to(contact.telephone, "tel:#{contact.telephone}") if contact.telephone.present?

    parts.join(', ').html_safe
  end

  def partner_address_info(partner)
    parts = []
    parts << link_to(partner.url, partner.url, target: '_blank' ) if partner.url.present?
    parts << partner.address.to_s if partner.address.present?

    parts.join(' | ').html_safe
  end
end
