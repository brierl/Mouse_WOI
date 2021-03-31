function [same_nodes,opp_nodes]=calc_fc_node(all_contrasts2,isbrain2,oi,mice)
% script to calculate fc

% IN:
%   all_contrasts2: oi.nVx, oi.nVy, contrast, time. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   oi: optical instrument properties
%   mice: struct with mouse specific properties

% OUT:
%   same_nodes: oi.nVx, oi.nVy, contrasts, same hemi nodes
%   opp_nodes: oi.nVx, oi.nVy, contrasts, contra hemi nodes

    isbrain_r=zeros(oi.nVx); isbrain_r(:,oi.nVx/2+1:end)=isbrain2(:,oi.nVx/2+1:end);
    isbrain_l=zeros(oi.nVx); isbrain_l(:,1:oi.nVx/2-1)=isbrain2(:,1:oi.nVx/2-1);

    % make seed traces, then FC maps, then FC matrices
    for i=1:length(oi.con_num) % loop through user specified contrasts
        strace=reshape(all_contrasts2(:,:,i,:),oi.nVx*oi.nVy,[]);
        R_seed(:,:,i)=atanh(normr(strace)*normr(strace)');
        clear strace
    end
    
    R_seed(R_seed<mice.zr)=0;
    R_seed(R_seed>=mice.zr)=1;
    nodes_r=sum(R_seed(:,isbrain_r==1,:),2);
    nodes_l=sum(R_seed(:,isbrain_l==1,:),2);
    nodes_r_rs=reshape(nodes_r,oi.nVx,oi.nVy,[]).*isbrain2;
    nodes_l_rs=reshape(nodes_l,oi.nVx,oi.nVy,[]).*isbrain2;
    same_nodes=NaN(oi.nVx,oi.nVy,length(oi.con_num));
    same_nodes(:,1:oi.nVx/2-1,:)=nodes_l_rs(:,1:oi.nVx/2-1,:);
    same_nodes(:,oi.nVx/2+1:end,:)=nodes_r_rs(:,oi.nVx/2+1:end,:);
    opp_nodes=NaN(oi.nVx,oi.nVy,length(oi.con_num));
    opp_nodes(:,1:oi.nVx/2-1,:)=nodes_r_rs(:,1:oi.nVx/2-1,:);
    opp_nodes(:,oi.nVx/2+1:end,:)=nodes_l_rs(:,oi.nVx/2+1:end,:);

    clear all_contrasts2

end
