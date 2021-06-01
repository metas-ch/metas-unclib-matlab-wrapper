% Metas.UncLib.Matlab.DistProp V2.3.1
% Michael Wollensack METAS - 28.02.2020
%
% DistProp Const:
% a = DistProp(value)
%
% DistProp Input (RealUncNumber)
% a = DistProp(value, standard_unc, (idof))
%
% DistProp Input (RealUncNumber)
% a = DistProp(value, standard_unc, description)
%
% DistProp Input (ComplexUncNumber)
% a = DistProp(value, [covariance], (description))
%
% DistProp Input (RealUncArray)
% [a] = DistProp([value], [covariance], (description))
%
% DistProp Input (ComplexUncArray)
% [a] = DistProp([value], [covariance], (description))
%
% DistProp Xml String
% a = DistProp(xml_string)
%
% DistProp Xml File
% a = DistProp(filepath, 'xml_file')
%
% DistProp Binary File
% a = DistProp(filepath, 'binary_file')
%
% DistProp System (RealUncNumber)
% a = DistProp(value, [sys_inputs], [sys_sensitivities], 'system')
%
% DistProp Input (RealUncNumber)
% a = DistProp(value, standard_unc, idof, id, description)

classdef DistProp
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
        function obj = DistProp(varargin)
            UncPropLoadNETAssemblies('DistProp');
            h = DistProp.UncHelper();
            switch nargin
                case 1
                    switch class(varargin{1})
                        case 'DistProp'
                            obj = varargin{1};
                        case 'double'
                            if numel(varargin{1}) == 1
                                if ~isreal(varargin{1})
                                    % ComplexUncNumber
                                    temp = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                                    temp.InitDblReIm(real(varargin{1}), imag(varargin{1}));
                                    obj.NetObject = temp;
                                else
                                    % RealUncNumber
                                    obj.NetObject = Metas.UncLib.DistProp.UncNumber(real(varargin{1}));
                                end
                            else
                                v = DistProp.Double2Array(varargin{1});
                                if ~isreal(varargin{1})
                                    % ComplexUncArray
                                    obj.NetObject = h.ComplexUncNArray(v);
                                else
                                    % RealUncArray
                                    obj.NetObject = h.RealUncNArray(v);
                                end
                            end
                        case 'Metas.UncLib.DistProp.UncNumber'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Complex<Metas*UncLib*DistProp*UncNumber>'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*DistProp*UncNumber>'
                            obj.NetObject = varargin{1};
                        case 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*DistProp*UncNumber>'
                            obj.NetObject = varargin{1};    
                        case 'char'
                            obj.NetObject = DistProp.XmlString2DistProp(varargin{1}).NetObject;
                        otherwise
                            error('Wrong type of input arguments')
                    end
                case 2
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double')
                        if numel(varargin{1}) == 1
                            if ~isreal(varargin{1})
                                % ComplexUncNumber
                                v = DistProp.Double2ComplexNumber(varargin{1});
                                cv = DistProp.Double2Array(varargin{2});
                                obj.NetObject = h.ComplexUncNumber(v, cv.Matrix, 0);
                            else
                                % RealUncNumber
                                obj.NetObject = Metas.UncLib.DistProp.UncNumber(varargin{1}, varargin{2});
                            end
                        else
                            v = DistProp.Double2Array(varargin{1});
                            cv = DistProp.Double2Array(varargin{2});
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
                                obj.NetObject = DistProp.XmlFile2DistProp(varargin{1}).NetObject;
                            case 'binary_file'
                                obj.NetObject = DistProp.BinaryFile2DistProp(varargin{1}).NetObject;
                            otherwise
                                error('Wrong file type')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 3
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'double')
                        obj.NetObject = Metas.UncLib.DistProp.UncNumber(varargin{1}, varargin{2}, varargin{3});
                    elseif isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'char')
                        if numel(varargin{1}) == 1
                            if ~isreal(varargin{1})
                                % ComplexUncNumber (Description)
                                v = DistProp.Double2ComplexNumber(varargin{1});
                                cv = DistProp.Double2Array(varargin{2});
                                obj.NetObject = h.ComplexUncNumber(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            else
                                % RealUncNumber (Description)
                                obj.NetObject = Metas.UncLib.DistProp.UncNumber(varargin{1}, varargin{2}, 0, UncInputId(), sprintf(varargin{3}));
                            end
                        else
                            v = DistProp.Double2Array(varargin{1});
                            cv = DistProp.Double2Array(varargin{2});
                            if ~isreal(varargin{1})
                                % ComplexUncArray (Description)
                                obj.NetObject = h.ComplexUncNArray(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            else
                                % RealUncArray (Description)
                                obj.NetObject = h.RealUncNArray(v, cv.Matrix, UncInputId(), sprintf(varargin{3}));
                            end
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 4
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'DistProp') && isa(varargin{3}, 'double') && isa(varargin{4}, 'char')
                        switch lower(varargin{4})
                            case 'system'
                                obj.NetObject = DistProp.System2DistProp(varargin{1}, varargin{2}, varargin{3}).NetObject;
                            otherwise
                                error('Wrong type of input arguments')
                        end
                    else
                        error('Wrong type of input arguments')
                    end
                case 5
                    if isa(varargin{1}, 'double') && isa(varargin{2}, 'double') && isa(varargin{3}, 'double') && isa(varargin{4}, 'Metas.UncLib.Core.Unc.InputId') && isa(varargin{5}, 'char')
                        if numel(varargin{1}) == 1
                            obj.NetObject = Metas.UncLib.DistProp.UncNumber(varargin{1}, varargin{2}, varargin{3}, varargin{4}, sprintf(varargin{5}));
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
                o = DistProp(Copy(obj.NetObject));
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
                n = double(obj.NetObject.ndims);
            else
                n = 1;
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
        function y = reshape(x, s)
            xm = DistProp.Convert2UncArray(x);
            xm.Reshape(int32(s(:)));
            y = DistProp.Convert2DistProp(xm);
        end
        function C = subsasgn(A, S, B)
            switch S(1).type
                case '()'
                    A = DistProp(A);
                    B = DistProp(B);
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
                                am = DistProp.Convert2UncArray(A);
                                am.Reshape(int32(s(:)));
                                A = DistProp.Convert2DistProp(am);
                            end
                            % Reshape B?
%                             if ni > nb
%                                 s = ones(1, ni);
%                                 sb = size(B);
%                                 s(end-numel(sb)+1:end) = sb;
%                                 bm = DistProp.Convert2UncArray(B);
%                                 bm.Reshape(int32(s(:)));
%                                 B = DistProp.Convert2DistProp(bm);
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
                                A2 = DistProp(zeros(s2));
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
                            am = DistProp.Convert2UncArray(A);
                            bm = DistProp.Convert2UncArray(B);
                            src_index  = DistProp.IndexMatrix(src_subs);
                            dest_index = DistProp.IndexMatrix(dest_subs);
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
                            C = DistProp.Convert2DistProp(am);
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
                        am = DistProp.Convert2UncArray(A);
                        src_index  = DistProp.IndexMatrix(src_subs);
                        dest_index = DistProp.IndexMatrix(dest_subs);
                        if A.IsComplex
                           bm = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                           bm.InitNd(int32(n(:)));
                        else
                           bm = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                           bm.InitNd(int32(n(:)));
                        end
                        if ni == 1
                            bm.SetItems1d(int32(dest_index - 1), am.GetItems1d(int32(src_index - 1)));
                        else
                            bm.SetItemsNd(int32(dest_index - 1), am.GetItemsNd(int32(src_index - 1)));
                        end
                        B = DistProp.Convert2DistProp(bm);
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
                a = DistProp(a);
                b = DistProp(varargin{1});
                if a.IsComplex && ~b.IsComplex
                    b = complex(b);
                end
                if ~a.IsComplex && b.IsComplex
                    a = complex(a);
                end
                am = DistProp.Convert2UncArray(a);
                bm = DistProp.Convert2UncArray(b);
                cm = am.HorzCat(bm);
                c = DistProp.Convert2DistProp(cm);
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
                a = DistProp(a);
                b = DistProp(varargin{1});
                if a.IsComplex && ~b.IsComplex
                    b = complex(b);
                end
                if ~a.IsComplex && b.IsComplex
                    a = complex(a);
                end
                am = DistProp.Convert2UncArray(a);
                bm = DistProp.Convert2UncArray(b);
                cm = am.VertCat(bm);
                c = DistProp.Convert2DistProp(cm);
            end
        end
        function d = get.Value(obj)
            d = get_value(obj);
        end
        function d = get.StdUnc(obj)
            d = get_stdunc(obj);
        end
        function b = get.IsComplex(obj)
            b = DistProp.IsComplexNet(obj.NetObject);
        end
        function b = get.IsArray(obj)
            b = DistProp.IsArrayNet(obj.NetObject);
        end
        function d = double(obj)
            d = get_value(obj);
        end
        function o = get_net_object(obj)
            o = obj.NetObject;
        end
        function d = get_value(obj)
            h = DistProp.UncHelper(); 
            d = DistProp.Convert2Double(h.GetValue(obj.NetObject));
        end
        function d = get_stdunc(obj)
            h = DistProp.UncHelper(); 
            d = DistProp.Convert2Double(h.GetStdUnc(obj.NetObject));
        end
        function d = get_idof(obj)
            h = DistProp.UncHelper(); 
            d = DistProp.Convert2Double(h.GetIDof(obj.NetObject));
        end
        function d = get_fcn_value(obj)
            h = DistProp.UncHelper(); 
            d = DistProp.Convert2Double(h.GetFcnValue(obj.NetObject));
        end
        function d = get_coverage_interval(obj, p)
            l = ToUncList(obj);
            h = DistProp.UncHelper();
            temp = h.GetCoverageInterval(l, p);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            d = DistProp.Convert2Double(array);
        end
        function d = get_moment(obj, n)
            h = DistProp.UncHelper(); 
            d = DistProp.Convert2Double(h.GetMoment(obj.NetObject, int32(n)));
        end
        function c = get_correlation(obj)
            l = ToUncList(obj);
            h = DistProp.UncHelper();
            temp = h.GetCorrelation(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = DistProp.Convert2Double(array);
        end
        function c = get_covariance(obj)
            l = ToUncList(obj);
            h = DistProp.UncHelper();
            temp = h.GetCovariance(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = DistProp.Convert2Double(array);
        end
        function c = get_jacobi(obj)
            l = ToUncList(obj);
            h = DistProp.UncHelper();
            temp = h.GetJacobi(l);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = DistProp.Convert2Double(array);
        end
        function c = get_jacobi2(x, y)
            x2 = ToUncList(x);
            y2 = ToUncList(y);
            h = DistProp.UncHelper();
            temp = h.GetJacobi2(x2, y2);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = DistProp.Convert2Double(array);
        end
        function c = get_unc_component(x, y)
            x2 = ToUncList(x);
            y2 = ToUncList(y);
            h = DistProp.UncHelper();
            temp = h.GetUncComponent(x2, y2);
            array = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.Core.Number'});
            array.Init2dData(temp);
            c = DistProp.Convert2Double(array);
        end
        function n = memsize(obj)
            n = double(obj.NetObject.memsize);
        end
        function y = uplus(x)
            y = x;
        end
        function y = uminus(x)
            y = DistProp(x.NetObject.Negative());
        end
        function z = plus(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.Add(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.LAdd(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = DistProp(y.NetObject.RAdd(x.NetObject));
            else
                z = DistProp(x.NetObject.Add(y.NetObject));
            end
        end
        function z = minus(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.Subtract(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.LSubtract(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = DistProp(y.NetObject.RSubtract(x.NetObject));
            else
                z = DistProp(x.NetObject.Subtract(y.NetObject));
            end
        end
        function z = times(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.Multiply(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.LMultiply(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = DistProp(y.NetObject.RMultiply(x.NetObject));
            else
                z = DistProp(x.NetObject.Multiply(y.NetObject));
            end
        end
        function z = rdivide(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            if ~x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.Divide(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.LDivide(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                z = DistProp(y.NetObject.RDivide(x.NetObject));
            else
                z = DistProp(x.NetObject.Divide(y.NetObject));
            end
        end
        function z = power(x,y)
            x = DistProp(x);
            y = DistProp(y);
            ydbl = double(y);
            yint = int32(ydbl);
            if (~y.IsArray) && (~y.IsComplex)
                yconst = (yint == ydbl) & (y.NetObject.IsConst);
            else
                yconst = false;
            end
            if yconst
                if x.IsArray
                    z = DistProp.Convert2DistProp(x.NetObject.Pow(yint));
                else
                    z = DistProp.Convert2DistProp(x.NetObject.Pow(yint));
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
                    z = DistProp.Convert2DistProp(x.NetObject.Pow(y.NetObject));
                elseif x.IsArray && ~y.IsArray
                    y = y.*ones(size(x));
                    z = x.^y;
                    % z = DistProp.Convert2DistProp(x.NetObject.LPow(y.NetObject));
                elseif ~x.IsArray && y.IsArray
                    x = x.*ones(size(y));
                    z = x.^y;
                    % z = DistProp.Convert2DistProp(y.NetObject.RPow(x.NetObject));
                else
                    z = DistProp.Convert2DistProp(x.NetObject.Pow(y.NetObject));
                end
            end
        end
        function y = complex(x)
            if x.IsComplex
                y = x;
            else
                if x.IsArray
                    y = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                else
                    y = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                end
                y.InitRe(x.NetObject);
                y = DistProp(y);
            end
        end
        function y = real(x)
            if x.IsComplex
                y = DistProp(x.NetObject.Real());
            else
                y = x;
            end
        end
        function y = imag(x)
            x = complex(x);
            y = DistProp(x.NetObject.Imag());
        end
        function y = conj(x)
            x = complex(x);
            y = DistProp(x.NetObject.Conj());
        end        
        function y = abs(x)
            y = DistProp(x.NetObject.Abs());
        end       
        function y = angle(x)
            x = complex(x);
            y = DistProp(x.NetObject.Angle());
        end
        function y = exp(x)
            y = DistProp(x.NetObject.Exp());
        end
        function y = log(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = DistProp(x.NetObject.Log());
        end
        function y = log10(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = DistProp(x.NetObject.Log10());
        end
        function y = sqrt(x)
            value = get_value(x); 
            if any(value(:) < 0)
                x = complex(x);
            end
            y = DistProp(x.NetObject.Sqrt());
        end
        function y = sign(x)
            y = sign(double(x));
        end
        function y = sin(x)
            y = DistProp(x.NetObject.Sin());
        end
        function y = cos(x)
            y = DistProp(x.NetObject.Cos());
        end
        function y = tan(x)
            y = DistProp(x.NetObject.Tan());
        end
        function y = sinh(x)
            y = DistProp(x.NetObject.Sinh());
        end
        function y = cosh(x)
            y = DistProp(x.NetObject.Cosh());
        end
        function y = tanh(x)
            y = DistProp(x.NetObject.Tanh());
        end
        function y = asin(x)
            y = DistProp(x.NetObject.Asin());
        end
        function y = acos(x)
            y = DistProp(x.NetObject.Acos());
        end
        function y = atan(x)
            y = DistProp(x.NetObject.Atan());
        end
        function z = atan2(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex || y.IsComplex
                error('Inputs must be real');
            end
            if ~x.IsArray && ~y.IsArray
                z = DistProp(x.NetObject.Atan2(y.NetObject));
            elseif x.IsArray && ~y.IsArray
                y = y.*ones(size(x));
                z = atan2(x,y);
                % z = DistProp(x.NetObject.LAtan2(y.NetObject));
            elseif ~x.IsArray && y.IsArray
                x = x.*ones(size(y));
                z = atan2(x,y);
                % z = DistProp(y.NetObject.RAtan2(x.NetObject));
            else
                z = DistProp(x.NetObject.Atan2(y.NetObject));
            end
        end
        function y = asinh(x)
            x = complex(x);
            y = DistProp(x.NetObject.Asinh());
        end
        function y = acosh(x)
            x = complex(x);
            y = DistProp(x.NetObject.Acosh());
        end
        function y = atanh(x)
            x = complex(x);
            y = DistProp(x.NetObject.Atanh());
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
                y = DistProp(x.NetObject.Transpose());
            else
                y = x;
            end
        end
        function y = ctranspose(x)
            if x.IsArray
                if x.IsComplex
                    y = DistProp(x.NetObject.CTranspose());
                else
                    y = DistProp(x.NetObject.Transpose());
                end
            else
                y = conj(x);
            end
        end
        function d = diag(A)
            am = DistProp.Convert2UncArray(A);
            s = size(A);
            if ((s(1) == 1) || (s(2) == 1))
                n = numel(A);
                if A.IsComplex
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    m.Zeros2d(n, n);
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    m.Zeros2d(n, n);
                end
                for i1 = 1:n
                    m.SetItem2d(i1-1, i1-1, am.GetItem1d(i1-1));
                end
                d = DistProp.Convert2DistProp(m);
            else
                if ((am.ndims ~= 2) || (s(1) ~= s(2)))
                    error('Matrix must be square.');
                end
                n1 = s(1);
                if A.IsComplex
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    m.Init2d(n1, 1);
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    m.Init2d(n1, 1);
                end
                for i1 = 1:n1
                    m.SetItem2d(i1-1, 0, am.GetItem2d(i1-1, i1-1));
                end
                d = DistProp.Convert2DistProp(m);
            end
        end
        function d = det(A)
            linalg = DistProp.LinAlg(A.IsComplex);
            d = DistProp.Convert2DistProp(linalg.Det(DistProp.Convert2UncArray(A)));
        end
        function d = inv(A)
            linalg = DistProp.LinAlg(A.IsComplex);
            d = DistProp.Convert2DistProp(linalg.Inv(DistProp.Convert2UncArray(A)));
        end
        function z = ldivide(x,y)
            z = y./x;
        end
        function z = mldivide(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if size(y, 2) == 1
                if x.IsComplex && ~y.IsComplex
                    y = complex(y);
                end
                if ~x.IsComplex && y.IsComplex
                    x = complex(x);
                end
                xm = DistProp.Convert2UncArray(x);
                yv = DistProp.Convert2UncArray(y);
                s = size(x);
                if s(1) == s(2)
                    linalg = DistProp.LinAlg(x.IsComplex);
                    zv = linalg.Solve(xm, yv);
                else
                    linalg = DistProp.LinAlg2(x.IsComplex);
                    zv = linalg.LstSqrSolve(xm, yv);
                end
                z = DistProp.Convert2DistProp(zv);
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
                error("Incorrect dimensions for raising a matrix to a power. Check that the matrix is square and the power is a scalar. To perform elementwise matrix powers, use '.^'.")
            end
        end
        function z = mrdivide(x,y)
            z = x*inv(y);
        end
        function z = mtimes(x,y)
            x = DistProp(x);
            y = DistProp(y);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            linalg = DistProp.LinAlg(x.IsComplex);
            xm = DistProp.Convert2UncArray(x);
            ym = DistProp.Convert2UncArray(y);
            zm = linalg.Dot(xm, ym);
            z = DistProp.Convert2DistProp(zm);
        end
        function [L, U, P] = lu(A)
            linalg = DistProp.LinAlg(A.IsComplex);
            am = DistProp.Convert2UncArray(A);
            temp = linalg.Lu(am);
            L = DistProp.Convert2DistProp(temp.l);
            U = DistProp.Convert2DistProp(temp.u);
            P = DistProp.Convert2DistProp(temp.p);
        end
        function x = lscov(A,b,V)
            A = DistProp(A);
            b = DistProp(b);
            [v, d] = eig(V);
            e = diag(d);
            for i = 1:length(e)
                if e(i) > 1e-15
                    e(i) = 1./e(i);
                else
                    e(i) = 0;
                end
            end
            W = DistProp(v*diag(e)*v');
            if A.IsComplex && ~b.IsComplex
                b = complex(b);
            end
            if ~A.IsComplex && b.IsComplex
                A = complex(A);
            end
            linalg = DistProp.LinAlg2(A.IsComplex);
            Am = DistProp.Convert2UncArray(A);
            bv = DistProp.Convert2UncArray(b);
            Wm = DistProp.Convert2UncArray(W);
            xv = linalg.WeightedLstSqrSolve(Am, bv, Wm);
            x = DistProp.Convert2DistProp(xv);
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
                        linalg = DistProp.LinAlg(x.IsComplex);
                        xm = DistProp.Convert2UncArray(x);
                        am = linalg.Sum(xm, i-1);
                        a = DistProp.Convert2DistProp(am);
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
                        linalg = DistProp.LinAlg(x.IsComplex);
                        xm = DistProp.Convert2UncArray(x);
                        am = linalg.Prod(xm, i-1);
                        a = DistProp.Convert2DistProp(am);
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
            numlib = DistProp.NumLib2(1);
            A = complex(A);
            s = size(A);
            am = DistProp.Convert2UncArray(A);
            xm = numlib.Fft(am);
            X = DistProp.Convert2DistProp(xm);
            X = reshape(X, s);
        end
        function X = ifft(A)
            numlib = DistProp.NumLib2(1);
            A = complex(A);
            s = size(A);
            am = DistProp.Convert2UncArray(A);
            xm = numlib.Ifft(am);
            X = DistProp.Convert2DistProp(xm);
            X = reshape(X, s);
        end
        function yy = interpolation(x, y, n, xx)
            x = double(x(:));
            y = DistProp(y);
            n = int32(n);
            s = size(xx);
            xx = double(xx(:));
            numlib = DistProp.NumLib(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            yym = numlib.Interpolation(x, ym, n, xx);
            yy = DistProp.Convert2DistProp(yym);
            yy = reshape(yy, s);
        end
        function yy = interpolation2(x, y, n, xx)
            x = double(x(:));
            y = DistProp(y);
            n = int32(n);
            s = size(xx);
            xx = double(xx(:));
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            yym = numlib.Interpolation2(x, ym, n, xx);
            yy = DistProp.Convert2DistProp(yym);
            yy = reshape(yy, s);
        end
        function yy = spline(x, y, xx, varargin)
            x = double(x(:));
            y = DistProp(y);
            s = size(xx);
            xx = double(xx(:));
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = DistProp.NumLib(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            yym = numlib.SplineInterpolation(x, ym, xx, sb, sv, eb, ev);
            yy = DistProp.Convert2DistProp(yym);
            yy = reshape(yy, s);
        end
        function yy = spline2(x, y, xx, varargin)
            x = double(x(:));
            y = DistProp(y);
            s = size(xx);
            xx = double(xx(:));
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            yym = numlib.SplineInterpolation2(x, ym, xx, sb, sv, eb, ev);
            yy = DistProp.Convert2DistProp(yym);
            yy = reshape(yy, s);
        end
        function p = splinecoefs(x, y, varargin)
            x = double(x(:));
            y = DistProp(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = DistProp.NumLib(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            pm = numlib.SplineCoefs(x, ym, sb, sv, eb, ev);
            p = DistProp.Convert2DistProp(pm);
        end
        function a = integrate(x, y, n)
            x = double(x(:));
            y = DistProp(y);
            n = int32(n);
            s = size(y);
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            am = numlib.Integrate(x, ym, n);
            a = DistProp.Convert2DistProp(am);
            a = reshape(a, s);
        end
        function a = integrate2(x, y, n)
            x = double(x(:));
            y = DistProp(y);
            n = int32(n);
            s = size(y);
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            am = numlib.Integrate2(x, ym, n);
            a = DistProp.Convert2DistProp(am);
            a = reshape(a, s);
        end
        function a = splineintegrate(x, y, varargin)
            x = double(x(:));
            y = DistProp(y);
            s = size(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            am = numlib.SplineIntegrate(x, ym, sb, sv, eb, ev);
            a = DistProp.Convert2DistProp(am);
            a = reshape(a, s);
        end
        function a = splineintegrate2(x, y, varargin)
            x = double(x(:));
            y = DistProp(y);
            s = size(y);
            [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin{:});
            numlib = DistProp.NumLib2(y.IsComplex);
            ym = DistProp.Convert2UncArray(y);
            am = numlib.SplineIntegrate2(x, ym, sb, sv, eb, ev);
            a = DistProp.Convert2DistProp(am);
            a = reshape(a, s);
         end
        function p = polyfit(x,y,n)
            x = DistProp(x);
            y = DistProp(y);
            n = int32(n);
            if x.IsComplex && ~y.IsComplex
                y = complex(y);
            end
            if ~x.IsComplex && y.IsComplex
                x = complex(x);
            end
            numlib = DistProp.NumLib(x.IsComplex);
            xm = DistProp.Convert2UncArray(x);
            ym = DistProp.Convert2UncArray(y);
            pm = numlib.PolyFit(xm, ym, n);
            p = DistProp.Convert2DistProp(pm);
        end
        function y = polyval(p,x)
            p = DistProp(p);
            x = DistProp(x);
            if p.IsComplex && ~x.IsComplex
                x = complex(x);
            end
            if ~p.IsComplex && x.IsComplex
                p = complex(p);
            end
            numlib = DistProp.NumLib(p.IsComplex);
            pm = DistProp.Convert2UncArray(p);
            xm = DistProp.Convert2UncArray(x);
            ym = numlib.PolyVal(pm, xm);
            y = DistProp.Convert2DistProp(ym);
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
            temp = Metas.UncLib.DistProp.UncList();
            l = temp.op_Implicit(obj.NetObject);
        end
        function [y, sb, sv, eb, ev] = SplineOptArgs(y, varargin)
            switch nargin
                case 1
                    sb = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                    sv = DistProp(0);
                    eb = Metas.UncLib.Core.SplineBoundary.Not_a_Knot;
                    ev = DistProp(0);
                case 2
                    sb = BoundaryArg(varargin{1});
                    sv = DistProp(0);
                    eb = sb;
                    ev = DistProp(0);
                 case 5
                    sb = BoundaryArg(varargin{1});
                    sv = DistProp(varargin{2});
                    sv = sv(1);
                    eb = BoundaryArg(varargin{3});
                    ev = DistProp(varargin{4});
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
            UncPropLoadNETAssemblies('DistProp');
            if bin.array
                if bin.complex
                    t = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                else
                    t = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                end
            else
                if bin.complex
                    t = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                else
                    t = Metas.UncLib.DistProp.UncNumber();
                end
            end
            v = t.BinaryDeserializeFromByteArray(bin.data(:));
            obj = DistProp(v);
        end
    end
    methods(Static = true, Access = private)
        function h = UncHelper()
            h = NET.createGeneric('Metas.UncLib.Core.Unc.GenericUnc', {'Metas.UncLib.DistProp.UncList', 'Metas.UncLib.DistProp.UncNumber'});
        end
        function l = LinAlg(complex)
            if complex
                lu_res = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexLuResult', 'Metas.UncLib.DistProp.UncNumber');
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexNArray', 'Metas.UncLib.DistProp.UncNumber');
                number = NET.GenericClass('Metas.UncLib.Core.Complex', 'Metas.UncLib.DistProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.LinAlg', {lu_res, narray, number});
            else
                lu_res = NET.GenericClass('Metas.UncLib.Core.Ndims.RealLuResult', 'Metas.UncLib.DistProp.UncNumber');
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.RealNArray', 'Metas.UncLib.DistProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.LinAlg', {lu_res, narray, 'Metas.UncLib.DistProp.UncNumber'});
            end            
        end
        function l = LinAlg2(complex)
            if complex
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexLinAlg', {'Metas.UncLib.DistProp.UncNumber'});
            else
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.RealLinAlg', {'Metas.UncLib.DistProp.UncNumber'});
            end            
        end
        function l = NumLib(complex)
            if complex
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.ComplexNArray', 'Metas.UncLib.DistProp.UncNumber');
                number = NET.GenericClass('Metas.UncLib.Core.Complex', 'Metas.UncLib.DistProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.NumLib', {narray, number});
            else
                narray = NET.GenericClass('Metas.UncLib.Core.Ndims.RealNArray', 'Metas.UncLib.DistProp.UncNumber');
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.NumLib', {narray, 'Metas.UncLib.DistProp.UncNumber'});
            end            
        end
        function l = NumLib2(complex)
            if complex
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNumLib', {'Metas.UncLib.DistProp.UncNumber'});
            else
                l = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNumLib', {'Metas.UncLib.DistProp.UncNumber'});
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
            if DistProp.IsArrayNet(x)
                if x.ndims == 1
                    s = [x.numel 1];
                else
                    s = int32(x.size);
                end
                if DistProp.IsComplexNet(x)
                    d = double(x.DblRealValue()) + 1i.*double(x.DblImagValue());
                else
                    d = double(x.DblValue());
                end
                d = reshape(d, s);
            else
                if DistProp.IsComplexNet(x)
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
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                else
                    m = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});                    
                end
                m.Init2d(1, 1);
                m.SetItem2d(0, 0, x.NetObject);
            end 
        end
        function u = Convert2DistProp(x)
            if DistProp.IsArrayNet(x)
                if x.numel == 1
                    u = DistProp(x.GetItem2d(0, 0));
                else
                    u = DistProp(x);
                    if ndims(u) == 1
                        u = reshape(u, size(u));
                    end
                end
            else
                u = DistProp(x);
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
                 isa(x, 'Metas.UncLib.Core.Complex<Metas*UncLib*DistProp*UncNumber>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*DistProp*UncNumber>'));
        end
        function b = IsArrayNet(x)
            b = (isa(x, 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.RealNArray<Metas*UncLib*DistProp*UncNumber>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*Core*Number>') | ...
                 isa(x, 'Metas.UncLib.Core.Ndims.ComplexNArray<Metas*UncLib*DistProp*UncNumber>'));
        end
        function obj = XmlString2DistProp(s)
            UncPropLoadNETAssemblies('DistProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                a = x.XmlDeserializeFromString(s);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    a = x.XmlDeserializeFromString(s);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                        a = x.XmlDeserializeFromString(s);
                    catch
                        try
                            x = Metas.UncLib.DistProp.UncNumber();
                            a = x.XmlDeserializeFromString(s);
                        catch
                            error('Wrong structure of xml string')
                        end
                    end
                end
            end
            obj = DistProp(a);
        end
        function obj = XmlFile2DistProp(fp)
            UncPropLoadNETAssemblies('DistProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                a = x.XmlDeserialize(fp);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    a = x.XmlDeserialize(fp);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                        a = x.XmlDeserialize(fp);
                    catch
                        try
                            x = Metas.UncLib.DistProp.UncNumber();
                            a = x.XmlDeserialize(fp);
                        catch
                            error('Wrong structure of xml file')
                        end
                    end
                end
            end
            obj = DistProp(a);
        end
        function obj = BinaryFile2DistProp(fp)
            UncPropLoadNETAssemblies('DistProp');
            try
                x = NET.createGeneric('Metas.UncLib.Core.Ndims.ComplexNArray', {'Metas.UncLib.DistProp.UncNumber'});
                a = x.BinaryDeserialize(fp);
            catch
                try
                    x = NET.createGeneric('Metas.UncLib.Core.Ndims.RealNArray', {'Metas.UncLib.DistProp.UncNumber'});
                    a = x.BinaryDeserialize(fp);
                catch
                    try
                        x = NET.createGeneric('Metas.UncLib.Core.Complex', {'Metas.UncLib.DistProp.UncNumber'});
                        a = x.BinaryDeserialize(fp);
                    catch
                        try
                            x = Metas.UncLib.DistProp.UncNumber();
                            a = x.BinaryDeserialize(fp);
                        catch
                            error('Wrong structure of binary file')
                        end
                    end
                end
            end
            obj = DistProp(a);
        end
        function obj = System2DistProp(value, sys_inputs, sys_sensitivities)
            % Workaround to pass a SAFEARRAY with only one element
            if numel(sys_sensitivities) == 1
                sys_sensitivities = [sys_sensitivities 0];
            end
            sys_inputs = DistProp(sys_inputs);
            sys_inputs = DistProp.Convert2UncArray(sys_inputs);
            unc_number = Metas.UncLib.DistProp.UncNumber();
            unc_number.Init(value, sys_inputs.data, sys_sensitivities(:));
            obj = DistProp(unc_number);
        end
    end 
end