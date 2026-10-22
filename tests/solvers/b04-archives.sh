#!/usr/bin/env bash
tar -C / -cjf /root/backup.tar.bz2 usr/local
tar -C / -czf /root/backup.tar.gz usr/local
