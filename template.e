indexing
   description: "Load a Template File (.tpl)"
   author: "Julien LEMOINE <speedblue@debian.org>"
   --| Copyright (C) 2002 Julien LEMOINE
   --| This program is free software; you can redistribute it and/or modify
   --| it under the terms of the GNU General Public License as published by
   --| the Free Software Foundation; either version 2 of the License, or
   --| (at your option) any later version.
   --| 
   --| This program is distributed in the hope that it will be useful,
   --| but WITHOUT ANY WARRANTY; without even the implied warranty of
   --| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   --| GNU General Public License for more details.
   --|
   --| You should have received a copy of the GNU General Public License
   --| along with this program; if not, write to the Free Software
   --| Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 

class TEMPLATE     

creation
   make

feature {ANY}
   make (path : STRING) is
      do
	 !!file.connect_to(path)
	 model := ""
	 if (file /= void and file.is_connected) then
	    from file.read_line until file.end_of_input loop
	       model := model + file.last_string + "%N"
	       if not file.end_of_input then
		  file.read_line
	       end
	    end
	    file.disconnect
	 end
      end
   
   start : BOOLEAN is
      do
	 if (model.count > 0) then
	    !!buff.make_from_string(model)
	    Result := true
	 else
	    Result := false
	 end
      end
   
   stop : STRING is
      do
	 Result := buff
      end
   
   replace (src, dst : STRING) is
      local
	 index : INTEGER
      do
	 index := buff.first_substring_index(src)
	 if (index > 0) then
	    buff.replace_substring(dst, 
				   index,
				   index + src.count)
	 end
      end
   
feature {TEMPLATE}
   file		: TEXT_FILE_READ
   buff		: STRING
   model	: STRING
end
