module Devise
  module Models
    # Suspendable Module, responsible for manual deactivation of a user account.
    #
    # Examples:
    #
    #    User.find(1).suspend!('Left the company')
    #
    module Suspendable
      def self.included(base)
        base.class_eval do
          validates_length_of :suspension_reason, :maximum => 250

          # basic sanitization
          before_validation do |acc|
            acc.suspension_reason.strip! if acc.suspension_reason
            acc.suspension_reason = nil  if acc.suspension_reason.blank?
            acc.suspension_reason = nil  if acc.suspended_at.blank?
          end
        end
      end

      def suspended?
        self.suspended_at?
      end

      def suspend!(reason = nil)
        return if suspended?
        self.suspended_at = Time.zone.now
        self.suspension_reason = reason
        self.save(:validate => false)
      end

      def unsuspend!
        return if !suspended?
        self.suspended_at = nil
        self.suspension_reason = nil
        self.save(:validate => false) if self.changed?
      end

      # make it compatible with latest devise
      def active_for_authentication?
        super && !suspended?
      end
      
      # Overwrites invalid_message from Devise::Models::Suspendable to define
      # the correct reason for sign in message
      def inactive_message
        suspended? ? :suspended : super
      end
      
      alias :active? :active_for_authentication?
      
    end
  end
end
