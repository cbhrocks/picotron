vec_eq = function(self, vec)
    for i=0,#self do
        if (self[i] != vec[i]) then
            return false
        end
    end
    return true
end
