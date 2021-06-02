% Metas.UncLib.Matlab.MCProp V2.4.8
% Michael Wollensack METAS - 28.05.2021
%
% MCProp Const:
% a = MCProp(value)
%
% MCProp Input (RealUncNumber)
% a = MCProp(value, standard_unc, (idof))
%
% MCProp Input (RealUncNumber)
% a = MCProp(value, standard_unc, description)
%
% MCProp Input (ComplexUncNumber)
% a = MCProp(value, [covariance], (description))
%
% MCProp Input (RealUncArray)
% [a] = MCProp([value], [covariance], (description))
%
% MCProp Input (ComplexUncArray)
% [a] = MCProp([value], [covariance], (description))
%
% MCProp From Samples
% a = MCProp([samples], 'samples', (description), (probability))
%
% MCProp Xml String
% a = MCProp(xml_string)
%
% MCProp Xml File
% a = MCProp(filepath, 'xml_file')
%
% MCProp Binary File
% a = MCProp(filepath, 'binary_file')
%
% MCProp System (RealUncNumber)
% a = MCProp(value, [sys_inputs], [sys_sensitivities], 'system')
%
% MCProp Input (RealUncNumber)
% a = MCProp(value, standard_unc, idof, id, description)

classdef MCProp
    properties
        NetObject
    end
    properties (SetAccess = private)
        Value
        StdUnc
        IsComplex
        IsArray
    end
    methods
        function obj = MCProp(varargin)
            UncPropLoadNETAssemblies('MCProp');
            h = MCProp.UncHelper();
            switch nargin
                case 1
                    switch class(varargin{1})
                        case 'MCProp'
                            obj = varargin{1};
                        case 'double'
                            if numel(varargin{1}) == 1
                                if ~isreal(varargin{1})
                                    % ComplexUncNumber
                                    temp = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                                    temp.InitDblReIm(real(varargin{1}), imag(varargin{1}));
                                    obj.NetObject = temp;
                                else
                                    % RealUncNumber
                                    obj.NetObject = Metas.UncLib.MCProp.UncNumber(real(varargin{1}));
                                end
                            else
                                v = MCProp.Double2Array(varargin{1});
                                if ~isreal(varargin{1})
                                    % ComplexUncArray
                                    obj.NetObject = h.ComplexUncNArray(v);
                                else
                                    % RealUncArray
                                    obj.NetObject = h.RealUncNArray(v);
                                end
                            end
                        case 'Metas.UncLib.MCProp.UncNumber'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Complex<Metas*UncLib*MCProp*UncNumber>'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*MCProp*UncNumber>'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*MCProp*UncNumber>'
                            obj.NetObject = varargin{1};    
                        case 'char'
                            obj.NetObject = MCProp.XmlString2MCProp(varargin{1}).NetObject;
                        otherwise
                            error('Wrong type of input arguments')
                    end
                case 2
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double')
                        if numel(varargin{1}) == 1
                            if ~isreal(varargin{1})
                                % ComplexUncNumber
                                v = MCProp.Double2ComplexNumber(varargin{1});
                                cv = MCProp.Double2Array(varargin{2});
                                obj.NetObject = h.ComplexUncNumber(v, cv.Matrix, 0);
                            else
                                % RealUncNumber
                                obj.NetObject = Metas.UncLib.MCProp.UncNumber(varargin{1}, varargin{2});
                            end
                        else
                            v = MCProp.Double2Array(varargin{1});
                            cv = MCProp.Double2Array(varargin{2});
                            if ~isreal(varargin{1})
                                % ComplexUncArray
                                obj.NetObject = h.ComplexUncNArray(v, cv.Matrix, 0);
                            else
                                % RealUncArray
                                obj.NetObject = h.RealUncNArray(v, cv.Matrix, 0);
                            end
                        end
                    elseif isa(varargin{1}, 'char') && isa(varargin{2}, 'char')
                        switch lower(varargin{2})
                            case 'xml_file'
                                obj.NetObject = MCProp.XmlFile2MCProp(varargin{1}).NetObject;
                            case 'binary_file'
                                obj.NetObject = MCProp.BinaryFile2MCProp(varargin{1}).NetObject;
                            otherwise
                                error('Wrong file type')
                        end
                    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'char')
                        switch lower(varargin{2})
                            case 'samples'
                                s = MCProp.Double2Array(varargin{1});
                                if size(varargin{1}, 2) == 1
                                    if ~isreal(varargin{1})
                                        % ComplexUncNumber
                                        obj.NetObject = h.ComplexUncNumberFromSamples(s.Vector);
                                    else
                                        % RealUncNumber
                                        obj.NetObject = h.RealUncNumberFromSamples(s.Vector);
                                    end
                                else
                                    if ~isreal(varargin{1})
                                        % ComplexUncArray
                                        obj.NetObject = h.ComplexUncNArrayFromSamples(s.Matrix);
                                    else
                                        % RealUncArray
                                        obj.NetObject = h.RealUncNArrayFromSamples(s.Matrix);
                                    end
                                end
                            otherwise
                                error('Wrong type of input arguments')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 3
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'double')
                        obj.NetObject = Metas.UncLib.MCProp.UncNumber(varargin{1}, varargin{2}, varargin{3});
                    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'char')
                        if numel(varargin{1}) == 1
                            if ~isreal(varargin{1})
                                % ComplexUncNumber (Description)
                                v = MCProp.Double2ComplexNumber(varargin{1});
                                cv = MCProp.Double2Array(varargin{2});
                                obj.NetObject = h.ComplexUncNumber(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            else
                                % RealUncNumber (Description)
                                obj.NetObject = Metas.UncLib.MCProp.UncNumber(varargin{1}, varargin{2}, 0, UncInputId(), sprintf(varargin{3}));
                            end
                        else
                            v = MCProp.Double2Array(varargin{1});
                            cv = MCProp.Double2Array(varargin{2});
                            if ~isreal(varargin{1})
                                % ComplexUncArray (Description)
                                obj.NetObject = h.ComplexUncNArray(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            else
                                % RealUncArray (Description)
                                obj.NetObject = h.RealUncNArray(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            end
                        end
                    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'char') && isa(varargin{3}, 'char')
                        switch lower(varargin{2})
                            case 'samples'
                                s = MCProp.Double2Array(varargin{1});
                                if size(varargin{1}, 2) == 1
                                    if ~isreal(varargin{1})
                                        % ComplexUncNumber
                                        obj.NetObject = h.ComplexUncNumberFromSamples(s.Vector, UncInputId(), sprintf(varargin{3}));
                                    else
                                        % RealUncNumber
                                        obj.NetObject = h.RealUncNumberFromSamples(s.Vector, UncInputId(), sprintf(varargin{3}));
                                    end
                                else
                                    if ~isreal(varargin{1})
                                        % ComplexUncArray
                                        obj.NetObject = h.ComplexUncNArrayFromSamples(s.Matrix, UncInputId(), sprintf(varargin{3}));
                                    else
                                        % RealUncArray
                                        obj.NetObject = h.RealUncNArrayFromSamples(s.Matrix, UncInputId(), sprintf(varargin{3}));
                                    end
                                end
                            otherwise
                                error('Wrong type of input arguments')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 4
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'MCProp') && isa(varargin{3}, 'double') && isa(varargin{4}, 'char')
                        switch lower(varargin{4})
                            case 'system'
                                obj.NetObject = MCProp.System2MCProp(varargin{1}, varargin{2}, varargin{3}).NetObject;
                            otherwise
                                error('Wrong type of input arguments')
                        end
                    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'char') && isa(varargin{3}, 'char') && isa(varargin{4}, 'double')
                        switch lower(varargin{2})
                            case 'samples'
                                s = MCProp.Double2Array(varargin{1});
                                if size(varargin{1}, 2) == 1
                                    if ~isreal(varargin{1})
                                        % ComplexUncNumber
                                        obj.NetObject = h.ComplexUncNumberFromSamples(s.Vector, UncInputId(), sprintf(varargin{3}), varargin{4});
                                    else
                                        % RealUncNumber
                                        obj.NetObject = h.RealUncNumberFromSamples(s.Vector, UncInputId(), sprintf(varargin{3}), varargin{4});
                                    end
                                else
                                    if ~isreal(varargin{1})
                                        % ComplexUncArray
                                        obj.NetObject = h.ComplexUncNArrayFromSamples(s.Matrix, UncInputId(), sprintf(varargin{3}), varargin{4});
                                    else
                                        % RealUncArray
                                        obj.NetObject = h.RealUncNArrayFromSamples(s.Matrix, UncInputId(), sprintf(varargin{3}), varargin{4});
                                    end
                                end
                            otherwise
                                error('Wrong type of input arguments')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 5
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'double') && isa(varargin{4}, 'Metas.UncLib.Core.Unc.InputId') && isa(varargin{5}, 'char')
                        if numel(varargin{1}) == 1
                            obj.NetObject = Metas.UncLib.MCProp.UncNumber(varargin{1}, varargin{2}, varargin{3}, varargin{4}, sprintf(varargin{5}));
                        else
                            error('Wrong type of input arguments')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                otherwise
                    error('Wrong number of input arguments')
            end 
        end
        function display(obj)
            name = inputname(1);
            df = '%g'; %get(0, 'Format');
            ds = get(0, 'FormatSpacing');
            if obj.IsArray
                if isequal(ds, 'compact')
                    disp([name,'.value = '])
                    disp(get_value(obj))
                    disp([name,'.standard_unc = '])
                    disp(get_stdunc(obj))
                else
                    disp(' ');
                    disp([name,'.value = '])
                    disp(' ');
                    disp(get_value(obj))
                    disp([name,'.standard_unc = '])
                    disp(' ');
                    disp(get_stdunc(obj))        
                end    
            else
                if obj.IsComplex
                    sreal = ['(' num2str(abs(get_value(real(obj))), df) ...
                             ' � ' num2str(get_stdunc(real(obj)), df) ')'];       
                    simag = ['(' num2str(abs(get_value(imag(obj))), df) ...
                             ' � ' num2str(get_stdunc(imag(obj)), df) ')'];
                    if (get_value(imag(obj)) < 0)
                        s = [sreal ' - ' simag 'i'];
                    else
                        s = [sreal ' + ' simag 'i'];
                    end
                else        
                    s = ['(' num2str(abs(get_value(obj)), df) ...
                         ' � ' num2str(get_stdunc(obj), df) ')'];
                end    
                if (get_value(real(obj)) < 0)
                    s = ['  -' s];
                else
                    s = ['   ' s];
                end
                if isequal(ds, 'compact')
                    disp([name,' = '])
                    disp(s)
                else
                    disp(' ');
                    disp([name,' = '])
                    disp(' ');
                    disp(s)
                    disp(' ');
                end    
            end
        end
        function o = copy(obj)
            if obj.IsArray
                o = MCProp(Copy(obj.NetObject));
            else
                o = obj;
            end
        end
        function index = end(obj, position, numindices)
            if (numindices == 1)
                index = numel(obj);
            else
                index = size(obj, position);
            end
        end
        function l = length(obj)
            if obj.IsArray
                if obj.NetObject.ndims == 1
                    s = [double(obj.NetObject.numel) 1];
                else
                    s = double(obj.NetObject.size);
                end
            else
                s = [1 1];
            end
            l = max(s);
        end
        function n = ndims(obj)
            if obj.IsArray
                n = max(2, double(obj.NetObject.ndims));
            else
                n = 2;
            end
        end
        function n = numel(obj)
            if obj.IsArray
                n = double(obj.NetObject.numel);
            else
                n = 1;
            end
        end
        function s = size(obj, varargin)
            if obj.IsArray
                if obj.NetObject.ndims == 1
                    s = [double(obj.NetObject.numel) 1];
                else
                    s = double(obj.NetObject.size);
                end
            else
                s = [1 1];
            end
            switch nargin
                case 1
                case 2
                    i = varargin{1};
                    if i < 1
                        error('Dimension argument must be a positive integer scalar within indexing range');
                    end
                    if i > numel(s)
                        s = 1;
                    else
                        s = s(i);
                    end
                otherwise
                    error('Too many input arguments')
            end
        end
        function y = reshape(x, varargin)
            %RESHAPE Reshape array.
            %   RESHAPE(X,M,N) or RESHAPE(X,[M,N]) returns the M-by-N matrix
            %   whose elements are taken columnwise from X. An error results
            %   if X does not have M*N elements.
            %
            %   RESHAPE(X,M,N,P,...) or RESHAPE(X,[M,N,P,...]) returns an
            %   N-D array with the same elements as X but reshaped to have
            %   the size M-by-N-by-P-by-.... The product of the specified
            %   dimensions, M*N*P*..., must be the same as NUMEL(X).
            %
            %   RESHAPE(X,...,[],...) calculates the length of the dimension
            %   represented by [], such that the product of the dimensions
            %   equals NUMEL(X). The value of NUMEL(X) must be evenly divisible
            %   by the product of the specified dimensions. You can use only one
            %   occurrence of [].
            %
            unknownDimensions = [];
            if numel(varargin) > 1
                unknownDimensions = cellfun(@isempty, varargin);
                if sum(unknownDimensions) > 1
                    error('Size can only have one unknown dimension.');
                elseif sum(unknownDimensions) == 1
                    % Temporarily replace empty dimension with 1, so
                    %   prod() can be used, as the unknown dimension is for now assumed to be 1,
                    %   numel(varargin) == numel(cell2mat(varargin)), and
                    %   checks on numeric values do not fail.
                    varargin(unknownDimensions) = {1};
                    % Correct value will be calculated after other arguments habe been checked.
                end
                if any(not(cellfun(@isscalar, varargin)))
                    error('Size arguments must be integer scalars.');
                end
                s = cell2mat(varargin);
            else
                s = double(varargin{1});
            end
            if numel(s) < 2
                error('Size vector must have at least two elements.');
            end
            if any(not(isreal(s)))
                error('Size argument cannot be complex.');
            end
            % check if size arguments have integer values (rounding has no effect and not inf, nan also fails this test).
            if any(ceil(s)~=s | isinf(s))
                error('Size arguments must be real integers.');
            end
            % Fix and check dimensions
            if sum(unknownDimensions) == 1
                if mod(numel(x), prod(s)) ~= 0
                    error('Product of known dimensions, %i, not divisible into total number of elements, %i.', prod(s), numel(x));
                else
                    s(unknownDimensions) = numel(x) / prod(s);
                end
            else
                if prod(s) ~= numel(x)
                    error('Number of elements must not change. Use [] as one of the size inputs to automatically calculate the appropriate size for that dimension.');
                end
            end
            xm = MCProp.Convert2UncArray(x);
            xm.Reshape(int32(s(:)));
            y = MCProp.Convert2MCProp(xm);
        end
        function C = subsasgn(A, S, B)
            switch S(1).type
                case '()'
                    A = MCProp(A);
                    B = MCProp(B);
                    if A.IsComplex && ~B.IsComplex
                        B = complex(B);
                    end
                    if ~A.IsComplex && B.IsComplex
                        A = complex(A);
                    end
                    ni = numel(S.subs);
                    na = ndims(A);
%                    nb = ndims(B);
                    if ((ni <= 1) || (ni >= na))
                        if ni == 0
                            C = A;
                        else
                            % Reshape A?
                            if ni > na
                                s = ones(1, ni);
                                s(1:na) = size(A);
                                am = MCProp.Convert2UncArray(A);
                                am.Reshape(int32(s(:)));
                                A = MCProp.Convert2MCProp(am);
                            end
                            % Reshape B?
%                             if ni > nb
%                                 s = ones(1, ni);
%                                 sb = size(B);
%                                 s(end-numel(sb)+1:end) = sb;
%                                 bm = MCProp.Convert2UncArray(B);
%                                 bm.Reshape(int32(s(:)));
%                                 B = MCProp.Convert2MCProp(bm);
%                             end
                            % Prepare Index
                            n = ones(1, ni);
                            max_index = zeros(1, ni);
                            dest_subs = S.subs;
                            src_subs = cell(1, ni);
                            for i = 1:ni
                                if strcmp(dest_subs{i}, ':')
                                    if ni == 1
                                        dest_subs{i} = 1:numel(A);
                                    else
                                        dest_subs{i} = 1:size(A, i);
                                    end
                                end
                                n(i) = numel(dest_subs{i});
                                max_index(i) = max(dest_subs{i});
                                src_subs{i} = 1:n(i);
                            end
                            % Resize A?
                            s = size(A);
                            if ((ni == 1) && (na <= 2))
                                if s(2) > 1
                                    max_index = [1 max_index];
                                else
                                    max_index = [max_index 1];
                                end
                            end
                            s2 = max(s, max_index);
                            if prod(s) ~= prod(s2)
                                A2 = MCProp(zeros(s2));
                                if B.IsComplex
                                    A2 = complex(A2);
                                end
                                if numel(A) == 0
                                    A = A2;
                                else
                                    S2.type = '()';
                                    if ni == 1
                                        S2.subs{1} = 1:numel(A);
                                    else
                                        for i = 1:ni
                                            S2.subs{i} = 1:s(i);
                                        end
                                    end
                                    A = subsasgn(A2, S2, A);
                                end
                            end
                            % Index Matrix
                            am = MCProp.Convert2UncArray(A);
                            bm = MCProp.Convert2UncArray(B);
                            src_index  = MCProp.IndexMatrix(src_subs);
                            dest_index = MCProp.IndexMatrix(dest_subs);
                            % Assign
                            nb = ndims(B);
                            if numel(B) == 1
                                if ni == 1
                                    am.SetSameItem1d(int32(dest_index - 1), bm.GetItem1d(0));
                                else
                                    am.SetSameItemNd(int32(dest_index - 1), bm.GetItem1d(0));
                                end
                            else
                                if ni == 1
                                    am.SetItems1d(int32(dest_index - 1), bm.GetItems1d(int32(src_index - 1)));
                                else
                                    src_index = src_index(:,1:nb);
                                    am.SetItemsNd(int32(dest_index - 1), bm.GetItemsNd(int32(src_index - 1)));
                                end
                            end
                            C = MCProp.Convert2MCProp(am);
                        end  
                    else
                        error('Matrix dimensions must agree.')
                    end
                otherwise
                    C = A;
                    C.(S.subs) = B;
            end
        end
        function B = subsref(A, S)
            switch S(1).type
                case '()'
                    ni = numel(S.subs);
                    if ni == 0
                        B = A;
                    else
                        n = ones(1, max(2, ni));
                        src_subs = S.subs;
                        dest_subs = cell(1, ni);
                        for i = 1:ni
                            if strcmp(src_subs{i}, ':')
                                if ni == 1
                                    src_subs{i} = 1:numel(A);
                                else
                                    src_subs{i} = 1:size(A, i);
                                end
                            end
                            n(i) = numel(src_subs{i});
                            dest_subs{i} = 1:n(i);
                        end
                        am = MCProp.Convert2UncArray(A);
                        src_index  = MCProp.IndexMatrix(src_subs);
                        dest_index = MCProp.IndexMatrix(dest_subs);
                        if A.IsComplex
                           bm = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                           bm.InitNd(int32(n(:)));
                        else
                           bm = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                           bm.InitNd(int32(n(:)));
                        end
                        if ni == 1
                            bm.SetItems1d(int32(dest_index - 1), am.GetItems1d(int32(src_index - 1)));
                        else
                            bm.SetItemsNd(int32(dest_index - 1), am.GetItemsNd(int32(src_index - 1)));
                        end
                        B = MCProp.Convert2MCProp(bm);
                        s = size(B);
                        if length(s) > 2 && s(end) == 1
                            B = reshape(B, s(1:end-1));
                        end
                    end
                otherwise
                    B = A.(S.subs);
            end
        end
        function c = horzcat(a, varargin)
            n = nargin - 1;
            if n == 0
                c = a;
            elseif n > 1
                for i = 1:n
                    a = [a varargin{i}];
                end
                c = a;
            else
                a = MCProp(a);
                b = MCProp(varargin{1});
                if a.IsComplex && ~b.IsComplex
                    b = complex(b);
                end
                if ~a.IsComplex && b.IsComplex
                    a = complex(a);
                end
                am = MCProp.Convert2UncArray(a);
                bm = MCProp.Convert2UncArray(b);
                cm = am.HorzCat(bm);
                c = MCProp.Convert2MCProp(cm);
            end
        end
        function c = vertcat(a, varargin)
            n = nargin - 1;
            if n == 0
                c = a;
            elseif n > 1
                for i = 1:n
                    a = [a; varargin{i}];
                end
                c = a;
            else
                a = MCProp(a);
                b = MCProp(varargin{1});
                if a.IsComplex && ~b.IsComplex
                    b = complex(b);
                end
                if ~a.IsComplex && b.IsComplex
                    a = complex(a);
                end
                am = MCProp.Convert2UncArray(a);
                bm = MCProp.Convert2UncArray(b);
                cm = am.VertCat(bm);
                c = MCProp.Convert2MCProp(cm);
            end
        end
        function d = get.Value(obj)
            d = get_value(obj);
        end
        function d = get.StdUnc(obj)
            d = get_stdunc(obj);
        end
        function b = get.IsComplex(obj)
            b = MCProp.IsComplexNet(obj.NetObject);
        end
        function b = get.IsArray(obj)
            b = MCProp.IsArrayNet(obj.NetObject);
        end
        function d = double(obj)
            d = get_value(obj);
        end
        function o = get_net_object(obj)
            o = obj.NetObject;
        end
        function d = get_value(obj)
            h = MCProp.UncHelper(); 
            d = MCProp.Convert2Double(h.GetValue(obj.NetObject));
        end
        function d = get_stdunc(obj)
            h = MCProp.UncHelper(); 
            d = MCProp.Convert2Double(h.GetStdUnc(obj.NetObject));
        end
        function d = get_idof(obj)
            h = MCProp.UncHelper(); 
            d = MCProp.Convert2Double(h.GetIDof(obj.NetObject));
        end
        function d = get_fcn_value(obj)
            h = MCProp.UncHelper(); 
            d = MCProp.Convert2Double(h.GetFcnValue(obj.NetObject));
        end
        function d = get_coverage_interval(obj, p)
            l = ToUncList(obj);
            h = MCProp.UncHelper();
            temp = h.GetCoverageInterval(l, p);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            d = MCProp.Convert2Double(array);
        end
        function d = get_moment(obj, n)
            h = MCProp.UncHelper(); 
            d = MCProp.Convert2Double(h.GetMoment(obj.NetObject, int32(n)));
        end
        function c = get_correlation(obj)
            l = ToUncList(obj);
            h = MCProp.UncHelper();
            temp = h.GetCorrelation(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = MCProp.Convert2Double(array);
        end
        function c = get_covariance(obj)
            l = ToUncList(obj);
            h = MCProp.UncHelper();
            temp = h.GetCovariance(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = MCProp.Convert2Double(array);
        end
        function c = get_jacobi(obj)
            l = ToUncList(obj);
            h = MCProp.UncHelper();
            temp = h.GetJacobi(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = MCProp.Convert2Double(array);
        end
        function c = get_jacobi2(x, y)
            x2 = ToUncList(x);
            y2 = ToUncList(y);
            h = MCProp.UncHelper();
            temp = h.GetJacobi2(x2, y2);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = MCProp.Convert2Double(array);
        end
        function c = get_unc_component(x, y)
            x2 = ToUncList(x);
            y2 = ToUncList(y);
            h = MCProp.UncHelper();
            temp = h.GetUncComponent(x2, y2);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = MCProp.Convert2Double(array);
        end
        function n = memsize(obj)
            n = double(obj.NetObject.memsize);
        end
        function y = uplus(x)
            y = x;
        end
        function y = uminus(x)
            y = MCProp(x.NetObject.Negative());
        end
        function z = plus(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.Add(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.LAdd(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = MCProp(y.NetObject.RAdd(x.NetObject));
            else
                z = MCProp(x.NetObject.Add(y.NetObject));
            end
        end
        function z = minus(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.Subtract(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.LSubtract(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = MCProp(y.NetObject.RSubtract(x.NetObject));
            else
                z = MCProp(x.NetObject.Subtract(y.NetObject));
            end
        end
        function z = times(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.Multiply(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.LMultiply(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = MCProp(y.NetObject.RMultiply(x.NetObject));
            else
                z = MCProp(x.NetObject.Multiply(y.NetObject));
            end
        end
        function z = rdivide(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.Divide(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.LDivide(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = MCProp(y.NetObject.RDivide(x.NetObject));
            else
                z = MCProp(x.NetObject.Divide(y.NetObject));
            end
        end
        function z = power(x,y)
            x = MCProp(x);
            y = MCProp(y);
            ydbl = double(y);
            yint = int32(ydbl);
            if (~y.IsArray) && (~y.IsComplex)
                yconst = (yint == ydbl) & (y.NetObject.IsConst);
            else
                yconst = false;
            end
            if yconst
                if x.IsArray
                    z = MCProp.Convert2MCProp(x.NetObject.Pow(yint));
                else
                    z = MCProp.Convert2MCProp(x.NetObject.Pow(yint));
                end
            else
                value = get_value(x); 
                if any(value(:) < 0)
                    x = complex(x);
                end
                if x.IsComplex && ~y.IsComplex
                    y = complex(y);
                end
                if ~x.IsComplex && y.IsComplex
                    x = complex(x);
                end
                if ~x.IsArray && ~y.IsArray
                    z = MCProp.Convert2MCProp(x.NetObject.Pow(y.NetObject));
                elseif x.IsArray && ~y.IsArray
                    y = y.*ones(size(x));
                    z = x.^y;
                    % z = MCProp.Convert2MCProp(x.NetObject.LPow(y.NetObject));
                elseif ~x.IsArray && y.IsArray
                    x = x.*ones(size(y));
                    z = x.^y;
                    % z = MCProp.Convert2MCProp(y.NetObject.RPow(x.NetObject));
                else
                    z = MCProp.Convert2MCProp(x.NetObject.Pow(y.NetObject));
                end
            end
        end
        function y = complex(x)
            if x.IsComplex
                y = x;
            else
                if x.IsArray
                    y = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                else
                    y = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                end
                y.InitRe(x.NetObject);
                y = MCProp(y);
            end
        end
        function y = real(x)
            if x.IsComplex
                y = MCProp(x.NetObject.Real());
            else
                y = x;
            end
        end
        function y = imag(x)
            x = complex(x);
            y = MCProp(x.NetObject.Imag());
        end
        function y = conj(x)
            x = complex(x);
            y = MCProp(x.NetObject.Conj());
        end        
        function y = abs(x)
            y = MCProp(x.NetObject.Abs());
        end       
        function y = angle(x)
            x = complex(x);
            y = MCProp(x.NetObject.Angle());
        end
        function y = exp(x)
            y = MCProp(x.NetObject.Exp());
        end
        function y = log(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = MCProp(x.NetObject.Log());
        end
        function y = log10(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = MCProp(x.NetObject.Log10());
        end
        function y = sqrt(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = MCProp(x.NetObject.Sqrt());
        end
        function y = sign(x)
            y = sign(double(x));
        end
        function y = sin(x)
            y = MCProp(x.NetObject.Sin());
        end
        function y = cos(x)
            y = MCProp(x.NetObject.Cos());
        end
        function y = tan(x)
            y = MCProp(x.NetObject.Tan());
        end
        function y = sinh(x)
            y = MCProp(x.NetObject.Sinh());
        end
        function y = cosh(x)
            y = MCProp(x.NetObject.Cosh());
        end
        function y = tanh(x)
            y = MCProp(x.NetObject.Tanh());
        end
        function y = asin(x)
            y = MCProp(x.NetObject.Asin());
        end
        function y = acos(x)
            y = MCProp(x.NetObject.Acos());
        end
        function y = atan(x)
            y = MCProp(x.NetObject.Atan());
        end
        function z = atan2(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex || y.IsComplex
                error('Inputs must be real');
            end
            if ~x.IsArray && ~y.IsArray
                z = MCProp(x.NetObject.Atan2(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                y = y.*ones(size(x));
                z = atan2(x,y);
                % z = MCProp(x.NetObject.LAtan2(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                x = x.*ones(size(y));
                z = atan2(x,y);
                % z = MCProp(y.NetObject.RAtan2(x.NetObject));
            else
                z = MCProp(x.NetObject.Atan2(y.NetObject));
            end
        end
        function y = asinh(x)
            x = complex(x);
            y = MCProp(x.NetObject.Asinh());
        end
        function y = acosh(x)
            x = complex(x);
            y = MCProp(x.NetObject.Acosh());
        end
        function y = atanh(x)
            x = complex(x);
            y = MCProp(x.NetObject.Atanh());
        end
        function z = eq(x,y)
            z = double(x) == double(y);
        end
        function z = ge(x,y)
            z = double(x) >= double(y);
        end
        function z = gt(x,y)
            z = double(x) > double(y);
        end
        function z = le(x,y)
            z = double(x) <= double(y);
        end
        function z = lt(x,y)
            z = double(x) < double(y);
        end
        function z = ne(x,y)
            z = double(x) ~= double(y);
        end
        function y = isfinite(x)
            y = isfinite(double(x));
        end
        function y = isinf(x)
            y = isinf(double(x));
        end
        function y = isnan(x)
            y = isnan(double(x));
        end
        function y = transpose(x)
            if x.IsArray
                y = MCProp(x.NetObject.Transpose());
            else
                y = x;
            end
        end
        function y = ctranspose(x)
            if x.IsArray
                if x.IsComplex
                    y = MCProp(x.NetObject.CTranspose());
                else
                    y = MCProp(x.NetObject.Transpose());
                end
            else
                y = conj(x);
            end
        end
        function d = diag(A)
            am = MCProp.Convert2UncArray(A);
            s = size(A);
            if ((s(1) == 1) || (s(2) == 1))
                n = numel(A);
                if A.IsComplex
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    m.Zeros2d(n, n);
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    m.Zeros2d(n, n);
                end
                for i1 = 1:n
                    m.SetItem2d(i1-1, i1-1, am.GetItem1d(i1-1));
                end
                d = MCProp.Convert2MCProp(m);
            else
                if ((am.ndims ~= 2) || (s(1) ~= s(2)))
                    error('Matrix must be square.');
                end
                n1 = s(1);
                if A.IsComplex
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    m.Init2d(n1, 1);
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    m.Init2d(n1, 1);
                end
                for i1 = 1:n1
                    m.SetItem2d(i1-1, 0, am.GetItem2d(i1-1, i1-1));
                end
                d = MCProp.Convert2MCProp(m);
            end
        end
        function d = det(A)
            linalg = MCProp.LinAlg(A.IsComplex);
            d = MCProp.Convert2MCProp(linalg.Det(MCProp.Convert2UncArray(A)));
        end
        function d = inv(A)
            linalg = MCProp.LinAlg(A.IsComplex);
            d = MCProp.Convert2MCProp(linalg.Inv(MCProp.Convert2UncArray(A)));
        end
        function z = ldivide(x,y)
            z = y./x;
        end
        function z = mldivide(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if size(y, 2) == 1
                if x.IsComplex && ~y.IsComplex
                    y = complex(y);
                end
                if ~x.IsComplex && y.IsComplex
                    x = complex(x);
                end
                xm = MCProp.Convert2UncArray(x);
                yv = MCProp.Convert2UncArray(y);
                s = size(x);
                if s(1) == s(2)
                    linalg = MCProp.LinAlg(x.IsComplex);
                    zv = linalg.Solve(xm, yv);
                else
                    linalg = MCProp.LinAlg2(x.IsComplex);
                    zv = linalg.LstSqrSolve(xm, yv);
                end
                z = MCProp.Convert2MCProp(zv);
            else
                z = inv(x)*y;
            end
        end
        function z = mpower(x,y)
            if (numel(x) == 1 && numel(y) == 1)
                % Power
                z = x.^y;
            elseif (numel(x) == 1)
                % Matrix Exponents
                [v, d] = eig(y);
                z = v*diag(x.^diag(d))/(v);
            elseif (numel(y) == 1)
                if (isa(y, 'double') && y == -1)
                    % Matrix Inverse
                    z = inv(x);
                else
                    % Matrix Power
                    [v, d] = eig(x);
                    z = v*diag(diag(d).^y)/(v);
                end
            else
                error('Incorrect dimensions for raising a matrix to a power. Check that the matrix is square and the power is a scalar. To perform elementwise matrix powers, use ''.^''.')
            end
        end
        function z = mrdivide(x,y)
            z = x*inv(y);
        end
        function z = mtimes(x,y)
            x = MCProp(x);
            y = MCProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            linalg = MCProp.LinAlg(x.IsComplex);
            xm = MCProp.Convert2UncArray(x);
            ym = MCProp.Convert2UncArray(y);
            zm = linalg.Dot(xm, ym);
            z = MCProp.Convert2MCProp(zm);
        end
        function [L, U, P] = lu(A)
            linalg = MCProp.LinAlg(A.IsComplex);
            am = MCProp.Convert2UncArray(A);
            temp = linalg.Lu(am);
            L = MCProp.Convert2MCProp(temp.l);
            U = MCProp.Convert2MCProp(temp.u);
            P = MCProp.Convert2MCProp(temp.p);
        end
        function x = lscov(A,b,V)
            A = MCProp(A);
            b = MCProp(b);
            [v, d] = eig(V);
            e = diag(d);
            for i = 1:length(e)
                if e(i) > 1e-15
                    e(i) = 1./e(i);
                else
                    e(i) = 0;
                end
            end
            W = MCProp(v*diag(e)*v');
            if A.IsComplex && ~b.IsComplex
                b = complex(b);
            end
            if ~A.IsComplex && b.IsComplex
                A = complex(A);
            end
            linalg = MCProp.LinAlg2(A.IsComplex);
            Am = MCProp.Convert2UncArray(A);
            bv = MCProp.Convert2UncArray(b);
            Wm = MCProp.Convert2UncArray(W);
            xv = linalg.WeightedLstSqrSolve(Am, bv, Wm);
            x = MCProp.Convert2MCProp(xv);
        end
        function a = sum(x, varargin)
            s = size(x);
            switch nargin
                case 1
                    % find first non-singleton dimension
                    f = [find(s > 1) 1];
                    a = sum(x, f(1));
                case {2,3}
                    i = varargin{1};
                    if i < 1
                        error('Dimension argument must be a positive integer scalar within indexing range');
                    end
                    if i > numel(s)
                        a = x;
                    else
                        linalg = MCProp.LinAlg(x.IsComplex);
                        xm = MCProp.Convert2UncArray(x);
                        am = linalg.Sum(xm, i-1);
                        a = MCProp.Convert2MCProp(am);
                    end
                otherwise
                    error('Too many input arguments')
            end
        end
        function a = prod(x, varargin)
            s = size(x);
            switch nargin
                case 1
                    % find first non-singleton dimension
                    f = [find(s > 1) 1];
                    a = prod(x, f(1));
                case {2,3}
                    i = varargin{1};
                    if i < 1
                        error('Dimension argument must be a positive integer scalar within indexing range');
                    end
                    if i > numel(s)
                        a = x;
                    else
                        linalg = MCProp.LinAlg(x.IsComplex);
                        xm = MCProp.Convert2UncArray(x);
                        am = linalg.Prod(xm, i-1);
                        a = MCProp.Convert2MCProp(am);
                    end
                otherwise
                    error('Too many input arguments')
            end
        end
        function a = mean(x, varargin)
            s = size(x);
            switch nargin
                case 1
                    % find first non-singleton dimension
                    f = [find(s > 1) 1];
                    a = mean(x, f(1));
                case 2
                    i = varargin{1};
                    if i < 1
                        error('Dimension argument must be a positive integer scalar within indexing range');
                    end
                    if i > numel(s)
                        a = x;
                    else
                        a = sum(x, i)./size(x, i);
                    end
                otherwise
                    error('Too many input arguments')
            end
        end
        function X = fft(A)
            numlib = MCProp.NumLib2(1);
            A = complex(A);
            s = size(A);
            am = MCProp.Convert2UncArray(A);
            xm = numlib.Fft(am);
            X = MCProp.Convert2MCProp(xm);
            X = reshape(X, s);
        end
        function X = ifft(A)
            numlib = MCProp.NumLib2(1);
            A = complex(A);
            s = size(A);
            am = MCProp.Convert2UncArray(A);
            xm = numlib.Ifft(am);
            X = MCProp.Convert2MCProp(xm);
            X = reshape(X, s);
        end
        function yy = interpolation(x, y, n, xx)
            x = double(x(:));
            y = MCProp(y);
            n = int32(n);
            s = size(xx);
            xx = double(xx(:));
            numlib = MCProp.NumLib(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            yym = numlib.Interpolation(x, ym, n, xx);
            yy = MCProp.Convert2MCProp(yym);
            yy = reshape(yy, s);
        end
        function yy = interpolation2(x, y, n, xx)
            x = double(x(:));
            y = MCProp(y);
            n = int32(n);
            s = size(xx);
            xx = double(xx(:));
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            yym = numlib.Interpolation2(x, ym, n, xx);
            yy = MCProp.Convert2MCProp(yym);
            yy = reshape(yy, s);
        end
        function yy = spline(x, y, xx, varargin)
            x = double(x(:));
            y = MCProp(y);
            s = size(xx);
            xx = double(xx(:));
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = MCProp.NumLib(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            yym = numlib.SplineInterpolation(x, ym, xx, sb, sv, eb, ev);
            yy = MCProp.Convert2MCProp(yym);
            yy = reshape(yy, s);
        end
        function yy = spline2(x, y, xx, varargin)
            x = double(x(:));
            y = MCProp(y);
            s = size(xx);
            xx = double(xx(:));
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            yym = numlib.SplineInterpolation2(x, ym, xx, sb, sv, eb, ev);
            yy = MCProp.Convert2MCProp(yym);
            yy = reshape(yy, s);
        end
        function p = splinecoefs(x, y, varargin)
            x = double(x(:));
            y = MCProp(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = MCProp.NumLib(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            pm = numlib.SplineCoefs(x, ym, sb, sv, eb, ev);
            p = MCProp.Convert2MCProp(pm);
        end
        function a = integrate(x, y, n)
            x = double(x(:));
            y = MCProp(y);
            n = int32(n);
            s = size(y);
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            am = numlib.Integrate(x, ym, n);
            a = MCProp.Convert2MCProp(am);
            a = reshape(a, s);
        end
        function a = integrate2(x, y, n)
            x = double(x(:));
            y = MCProp(y);
            n = int32(n);
            s = size(y);
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            am = numlib.Integrate2(x, ym, n);
            a = MCProp.Convert2MCProp(am);
            a = reshape(a, s);
        end
        function a = splineintegrate(x, y, varargin)
            x = double(x(:));
            y = MCProp(y);
            s = size(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            am = numlib.SplineIntegrate(x, ym, sb, sv, eb, ev);
            a = MCProp.Convert2MCProp(am);
            a = reshape(a, s);
        end
        function a = splineintegrate2(x, y, varargin)
            x = double(x(:));
            y = MCProp(y);
            s = size(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = MCProp.NumLib2(y.IsComplex);
            ym = MCProp.Convert2UncArray(y);
            am = numlib.SplineIntegrate2(x, ym, sb, sv, eb, ev);
            a = MCProp.Convert2MCProp(am);
            a = reshape(a, s);
         end
        function p = polyfit(x,y,n)
            x = MCProp(x);
            y = MCProp(y);
            n = int32(n);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            numlib = MCProp.NumLib(x.IsComplex);
            xm = MCProp.Convert2UncArray(x);
            ym = MCProp.Convert2UncArray(y);
            pm = numlib.PolyFit(xm, ym, n);
            p = MCProp.Convert2MCProp(pm);
        end
        function y = polyval(p,x)
            p = MCProp(p);
            x = MCProp(x);
            if p.IsComplex && ~x.IsComplex
                x = complex(x);
            end
            if ~p.IsComplex && x.IsComplex
                p = complex(p);
            end
            numlib = MCProp.NumLib(p.IsComplex);
            pm = MCProp.Convert2UncArray(p);
            xm = MCProp.Convert2UncArray(x);
            ym = numlib.PolyVal(pm, xm);
            y = MCProp.Convert2MCProp(ym);
        end
        function binary_file(x, filepath)
            x.NetObject.BinarySerialize(filepath);
        end
        function xml_file(x, filepath)
            x.NetObject.XmlSerialize(filepath);
        end
        function s = xml_string(x)
            s = char(x.NetObject.XmlSerializeToString());
        end
        function bin = saveobj(obj)
            bin.data = uint8(obj.NetObject.BinarySerializeToByteArray());
            bin.array = obj.IsArray;
            bin.complex = obj.IsComplex;
        end
    end
    methods(Access = private)
        function l = ToUncList(obj)
            temp = Metas.UncLib.MCProp.UncList();
            l = temp.op_Implicit(obj.NetObject);
        end
        function [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin)
            switch nargin
                case 1
                    sb = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                    sv = MCProp(0);
                    eb = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                    ev = MCProp(0);
                case 2
                    sb = BoundaryArg(varargin{1});
                    sv = MCProp(0);
                    eb = sb;
                    ev = MCProp(0);
                 case 5
                    sb = BoundaryArg(varargin{1});
                    sv = MCProp(varargin{2});
                    sv = sv(1);
                    eb = BoundaryArg(varargin{3});
                    ev = MCProp(varargin{4});
                    ev = ev(1);
                otherwise
                    error('Wrong number of input arguments')
            end
            if (y.IsComplex || sv.IsComplex || ev.IsComplex)
                y = complex(y);
                sv = complex(sv);
                ev = complex(ev);
            end
            sv = sv.NetObject;
            ev = ev.NetObject;
            
            function c = BoundaryArg(b)
                if (ischar(b))
                    b = lower(b);
                    switch b
                        case 'not-a-knot'
                            c = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                        case 'not a knot'
                            c = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                        case 'natural spline'
                            c = Metas.UncLib.Core.SplineBoundary.Natural_Spline;
                        case 'first derivative'
                            c = Metas.UncLib.Core.SplineBoundary.First_Derivative;
                        case '1st derivative'
                            c = Metas.UncLib.Core.SplineBoundary.First_Derivative;
                        case 'second derivative'
                            c = Metas.UncLib.Core.SplineBoundary.Second_Derivative;
                        case '2nd derivative'
                            c = Metas.UncLib.Core.SplineBoundary.Second_Derivative;
                        otherwise
                            error('Unknown spline boundary mode')
                    end
                elseif (isa(b,'Metas.UncLib.Core.SplineBoundary'))
                    c = b;
                else
                    error('Unknown spline boundary type')
                end
            end
        end
    end
    methods(Static = true)
        function obj = loadobj(bin)
            UncPropLoadNETAssemblies('MCProp');
            if bin.array
                if bin.complex
                    t = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                else
                    t = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                end
            else
                if bin.complex
                    t = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                else
                    t = Metas.UncLib.MCProp.UncNumber();
                end
            end
            v = t.BinaryDeserializeFromByteArray(bin.data(:));
            obj = MCProp(v);
        end
    end
    methods(Static = true, Access = private)
        function h = UncHelper()
            h = NET.createGeneric('Metas.UncLib.Core.Unc.GenericUnc', {'Metas.UncLib.MCProp.UncList', 'Metas.UncLib.MCProp.UncNumber'});
        end
        function l = LinAlg(complex)
            if complex
                lu_res = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexLuResult', 'Metas.UncLib.MCProp.UncNumber');
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexNArray', 'Metas.UncLib.MCProp.UncNumber');
                number = NET.GenericClass('Metas.UncLib.Core.Complex', 'Metas.UncLib.MCProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.LinAlg', {lu_res, narray, number});
            else
                lu_res = NET.GenericClass('Metas.UncLib.Core.Ndims.RealLuResult', 'Metas.UncLib.MCProp.UncNumber');
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.RealNArray', 'Metas.UncLib.MCProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.LinAlg', {lu_res, narray, 'Metas.UncLib.MCProp.UncNumber'});
            end            
        end
        function l = LinAlg2(complex)
            if complex
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexLinAlg', {'Metas.UncLib.MCProp.UncNumber'});
            else
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.RealLinAlg', {'Metas.UncLib.MCProp.UncNumber'});
            end            
        end
        function l = NumLib(complex)
            if complex
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexNArray', 'Metas.UncLib.MCProp.UncNumber');
                number = NET.GenericClass('Metas.UncLib.Core.Complex', 'Metas.UncLib.MCProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.NumLib', {narray, number});
            else
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.RealNArray', 'Metas.UncLib.MCProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.NumLib', {narray, 'Metas.UncLib.MCProp.UncNumber'});
            end            
        end
        function l = NumLib2(complex)
            if complex
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNumLib', {'Metas.UncLib.MCProp.UncNumber'});
            else
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNumLib', {'Metas.UncLib.MCProp.UncNumber'});
            end
        end
        function c = Double2ComplexNumber(d)
            c = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.Core.Number'});
            c.InitDblReIm(real(d), imag(d));
        end        
        function a = Double2Array(d)
            if numel(d) == 0
                a = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
                a.Init2d(0, 0);
            else
                s = size(d);
                s = int32(s(:));
                d2 = d(:);
                if ~isreal(d)
                    a = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.Core.Number'});
                    a.InitDblReIm(real(d2), imag(d2));
                else
                    a = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
                    a.InitDbl(real(d2));
                end
                a.Reshape(s)
            end
        end
        function d = Convert2Double(x)
            if MCProp.IsArrayNet(x)
                if x.ndims == 1
                    s = [x.numel 1];
                else
                    s = int32(x.size);
                end
                if MCProp.IsComplexNet(x)
                    d = double(x.DblRealValue()) + 1i.*double(x.DblImagValue());
                else
                    d = double(x.DblValue());
                end
                d = reshape(d, s);
            else
                if MCProp.IsComplexNet(x)
                    d = x.DblRealValue() + 1i*x.DblImagValue();
                else
                    d = x.Value;
                end
            end
        end
        function m = Convert2UncArray(x)
            if x.IsArray
                m = x.NetObject;
            else
                if x.IsComplex
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});                    
                end
                m.Init2d(1, 1);
                m.SetItem2d(0, 0, x.NetObject);
            end 
        end
        function u = Convert2MCProp(x)
            if MCProp.IsArrayNet(x)
                if x.numel == 1
                    u = MCProp(x.GetItem2d(0, 0));
                else
                    u = MCProp(x);
                    if ndims(u) == 1
                        u = reshape(u, size(u));
                    end
                end
            else
                u = MCProp(x);
            end
        end
        function m = IndexMatrix(subs)
            n2 = numel(subs);
            s = zeros(1, n2);
            for i2 = 1:n2
                s(i2) = numel(subs{i2});
            end
            n1 = prod(s);
            m = zeros(n1, n2);
            temp = 1;
            for i2 = 1:n2
                temp_index = mod(floor((0:n1-1)./temp), s(i2)) + 1;
                m(:,i2) = subs{i2}(temp_index);
                temp = temp*s(i2); 
            end
        end
        function b = IsComplexNet(x)
            b = (isa(x, 'Metas.UncLib.Core.Complex<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Complex<Metas*UncLib*MCProp*UncNumber>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*MCProp*UncNumber>'));
        end
        function b = IsArrayNet(x)
            b = (isa(x, 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*MCProp*UncNumber>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*MCProp*UncNumber>'));
        end
        function obj = XmlString2MCProp(s)
            UncPropLoadNETAssemblies('MCProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                a = x.XmlDeserializeFromString(s);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    a = x.XmlDeserializeFromString(s);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                        a = x.XmlDeserializeFromString(s);
                    catch
                        try
                            x = Metas.UncLib.MCProp.UncNumber();
                            a = x.XmlDeserializeFromString(s);
                        catch
                            error('Wrong structure of xml string')
                        end
                    end
                end
            end
            obj = MCProp(a);
        end
        function obj = XmlFile2MCProp(fp)
            UncPropLoadNETAssemblies('MCProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                a = x.XmlDeserialize(fp);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    a = x.XmlDeserialize(fp);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                        a = x.XmlDeserialize(fp);
                    catch
                        try
                            x = Metas.UncLib.MCProp.UncNumber();
                            a = x.XmlDeserialize(fp);
                        catch
                            error('Wrong structure of xml file')
                        end
                    end
                end
            end
            obj = MCProp(a);
        end
        function obj = BinaryFile2MCProp(fp)
            UncPropLoadNETAssemblies('MCProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.MCProp.UncNumber'});
                a = x.BinaryDeserialize(fp);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.MCProp.UncNumber'});
                    a = x.BinaryDeserialize(fp);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.MCProp.UncNumber'});
                        a = x.BinaryDeserialize(fp);
                    catch
                        try
                            x = Metas.UncLib.MCProp.UncNumber();
                            a = x.BinaryDeserialize(fp);
                        catch
                            error('Wrong structure of binary file')
                        end
                    end
                end
            end
            obj = MCProp(a);
        end
        function obj = System2MCProp(value, sys_inputs, sys_sensitivities)
            % Workaround to pass a SAFEARRAY with only one element
            if numel(sys_sensitivities) == 1
                sys_sensitivities = [sys_sensitivities 0];
            end
            sys_inputs = MCProp(sys_inputs);
            sys_inputs = MCProp.Convert2UncArray(sys_inputs);
            unc_number = Metas.UncLib.MCProp.UncNumber();
            unc_number.Init(value, sys_inputs.data, sys_sensitivities(:));
            obj = MCProp(unc_number);
        end
    end 
end