indexing
   description: "Search in AST"
   author: "Julien LEMOINE <speedblue@debian.org>"
   --| This program is free software; you can redistribute it and/or modify
   --| it under the terms of the GNU General Public License as published by
   --| the Free Software Foundation; either version 2 of the License, or
   --| (at your option) any later version.

class GREP_VISITOR     

inherit DEFAULT_VISITOR
      rename
	 make as make_default
      redefine
	 visit_string, sub_visit

creation
   make
   
feature {ANY}   
   make(a : AST; rexp : STRING; case_sensitive : BOOLEAN) is
      do
	 make_default(a)
	 !!regexp.compile(rexp, case_sensitive)
	 res := false
      end
   
   get_result : BOOLEAN is
      do
	 Result := res
      end
   
feature {GREP_VISITOR}
   sub_visit (doc : DOCUMENT) is
      require
	 doc /= void
      do
	 document := doc
	 visit_strings(doc.authors)
	 visit_strings(doc.parts)
	 visit_comments(doc.comments)
	 visit_string(doc.summary)
	 visit_string(doc.date)
	 visit_string(doc.type)
	 visit_string(doc.file)
	 visit_string(doc.title)
	 visit_string(doc.language)
      end
   
   visit_string(str : STRING) is
      do
	 if (str /= void) then
	    if (regexp.compiled and regexp.matches(str)) then
	       res := true
	       if (document /= void) then
		  document.set_mark(true)
	       end
	    end
	 end
      end
   
feature {GREP_VISITOR}
   regexp	: LX_DFA_REGULAR_EXPRESSION
   res		: BOOLEAN
   document	: DOCUMENT
end

