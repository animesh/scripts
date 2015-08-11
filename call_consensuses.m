function [s f sources] = call_consensuses(ams,ass, Assemblies)

if isa(ams,'double')
    ams = {ams};
end

if isa(ass{1},'char')
    ass = {ass};
end


s = cell(size(ams));
f = cell(size(ams));
sources = cell(size(ams));

for li = 1:size(ams,1)
    
    % Call consensus
    [s{li} f{li} sources{li}] = call_consensus(ams{li},ass{li}, Assemblies);
end
