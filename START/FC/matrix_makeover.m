function [Rs_Data_rs]=matrix_makeover(Rs_Data)
% reshape matrices into networks

% IN:
%   Rs_Data: seed x seed x contrast FC matrix

% OUT:
%   Rs_Data_rs: re-positioned FC matrix with diagonal blacked out

    if size(Rs_Data,1)==26
        empty=zeros(26,26,size(Rs_Data,3));

        % reshape matrices into networks
        for j=1:size(Rs_Data,3)
            jj=1;
            for ii=[2 3 4 13 1 5 10 11 12 6 7 9 8 15 16 17 26 14 18 23 24 25 19 20 22 21]

                reform=squeeze(Rs_Data(ii,:,j)); 
                empty(jj,:,j)=reform(1,[2 3 4 13 1 5 10 11 12 6 7 9 8 15 16 17 26 14 18 23 24 25 19 20 22 21]);
                jj=jj+1;
                clear reform

            end
        end

        % make matrix diagonal NaN
        for ii=1:26
            for j=1:26
                if ii==j
                    empty(ii,j,:)=NaN;
                end
            end
        end
        Rs_Data_rs=empty;
    else
        Rs_Data_rs=Rs_Data;
    end

end