% http://www.cs.bu.edu/teaching/c/queue/array/types.html
% Extending handle is very important!!
% See http://stackoverflow.com/a/13867697/148668
classdef queue_array < handle
  properties ( Access = public )
    elems = zeros(1,1);
    first = 0;
    last = 0;
  end
  methods
    function this = Queue()
    end
    function push(this,elem)
      this.last = this.last+1;
      if this.last > numel(this.elems)
        this.elems = [this.elems;zeros(numel(this.elems),1)];
      end
      this.elems(this.last) = elem;
    end
    function ret = empty(this)
      ret = this.last-this.first == 0;
    end
    function elem = front(this)
      if this.empty()
        error('Empty Queue');
      end
      elem = this.elems(this.first+1);
    end
    function pop(this)
      this.first = this.first + 1;
      if (this.last-this.first)<0.25*numel(this.elems)
        this.elems = this.elems(this.first+1:this.last);
        this.first = 0;
        this.last = numel(this.elems); 
      end
    end
  end
end