np = py.importlib.import_module('numpy');
ops = np.load('ops.npy', pyargs('allow_pickle',true));

% Get keys
keys = ops_dict.keys();

% Access specific value, e.g. 'Lx'
Lx=double(ops_dict{'Lx'});
Ly=double(ops_dict{'Ly'});

