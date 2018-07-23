# encoding: utf-8
#
# Redmine plugin to show all files as file icons or thumnails
#
# Copyright © 2018 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module RedminePreviewDocx
  module Patches 
    module ApplicationHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 
          
		 def preview_docx_tag(attachment, options={})
		   _size = options.delete(:size) || 1600
		   content_tag(
		       :iframe,
		       "",
			   { :style  => "width: 100%; height: 16px;",
			     :seamless => "seamless",
			     :scrolling => "no",
			     :frameborder => "0",
			     :allowtransparency => "true",
			     :title  => attachment.filename,
                 :src    => preview_docx_path(attachment, :size => _size),
                 :onload => "resizeIframe(this);"
			    }.merge(options)
		   )
		 end                      
        end #base
      end #self

      module InstanceMethods    
      end #module
      
    end #module
  end #module
end #module

unless ApplicationHelper.included_modules.include?(RedminePreviewDocx::Patches::ApplicationHelperPatch)
    ApplicationHelper.send(:include, RedminePreviewDocx::Patches::ApplicationHelperPatch)
end


