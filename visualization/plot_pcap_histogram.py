#! /usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import numpy as np
import os
import pyshark


def plot_histogram(times, host):
    matplotlib.rcParams['figure.dpi'] = 300

    lw_edge, up_edge = round(min(times)) - 0.5, round(max(times)) + 0.5
    num_edges = int(up_edge - lw_edge) + 1
    bins = np.linspace(lw_edge, up_edge, num_edges)

    plt.figure(figsize=(6, 4))
    plt.hist(times, bins=bins, edgecolor='midnightblue')
    plt.xlim((min(0, lw_edge), min(3 * np.mean(times), max(times))))

    times_type = 'inter-sending' if host == 'server' else 'interarrival'
    plt.xlabel('{} time (in ms)'.format(times_type.capitalize()))
    plt.ylabel('Frequency')
    plt.title('{} {} times distribution'.format(host.capitalize(), times_type))

    plt.get_current_fig_manager().set_window_title(host.capitalize())
    plt.tight_layout()
    plt.show()
    plt.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script for plotting a histograms of inter-sending/interarrival times, '
                                                 'given a pcap file as input.')
    parser.add_argument('pcap_file', metavar='pcap_file', type=str, nargs='?', default=None, help='pcap file to parse.')
    parser.add_argument('pcap_host', metavar='pcap_host', type=str, nargs='?', help='host on which the pcap file has '
                        'been dumped (either server or client).')
    args = parser.parse_args()

    # read the command-line arguments
    pcap_file, pcap_host = args.pcap_file, args.pcap_host
    if pcap_file is None:
        print('Provide a pcap file to parse')
        exit(0)
    elif not os.path.exists(pcap_file):
        print('The \'{}\' file does not exist\n'.format(
            os.path.join(os.path.basename(os.path.dirname(pcap_file)), os.path.basename(pcap_file))
        ))
        exit(0)
    if pcap_host not in ['server', 'client']:
        print('Unknown pcap_host \'{}\' (only \'server\' and \'client\' are allowed)'.format(pcap_host))
        exit(0)

    # parse the pcap file, keeping only the RTMP packets
    pyshark.FileCapture.SUMMARIES_BATCH_SIZE = 5
    capture = pyshark.FileCapture(pcap_file, only_summaries=True, display_filter='rtmpt')

    # extract the inter-sending/interarrival times (in ms)
    inter_times = []
    previous_packet_time = 0.0
    for current_packet in capture:
        inter_times.append((float(current_packet.time) - previous_packet_time) * 1000)
        previous_packet_time = float(current_packet.time)
    if len(inter_times) > 0:
        del inter_times[0]

    # show the inter-sending/interarrival times as a histogram
    if len(inter_times) > 0:
        plot_histogram(inter_times, pcap_host)
    else:
        print('The {} file is empty\n'.format(os.path.basename(pcap_file)))
