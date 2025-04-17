#!/bin/sh

if command -v yum 2>&1 >/dev/null
then
    yum remove -y eyez-agentmanager eyez-agent
elif command -v apt 2>&1 >/dev/null
then
    apt remove -y eyez-agentmanager eyez-agent
else
    echo "Failed to uninstall"
    exit 1
fi

rm -rf /opt/zscaler/installation/*
rmdir /opt/zscaler/installation
